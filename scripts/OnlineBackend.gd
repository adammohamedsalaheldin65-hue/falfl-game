extends Node

signal auth_completed(success: bool, mode: String, data: Dictionary, message: String)
signal cloud_save_completed(success: bool, message: String)
signal cloud_load_completed(success: bool, found: bool, data: Dictionary, message: String)

var project_url: String = "https://igqjgvnwxvgxujxhfgkh.supabase.co"
var publishable_key: String = "sb_publishable_uE2Fw67mFgY5qeAcgn-WNQ_sNgqU2ti"

var access_token: String = ""
var refresh_token: String = ""
var user_id: String = ""
var user_email: String = ""

var pending_email: String = ""


func _ready() -> void:
	load_runtime_config()


func is_configured() -> bool:
	return project_url.begins_with("https://") and publishable_key.length() > 12


func has_session() -> bool:
	return is_configured() and access_token != "" and user_id != ""


func configure(url: String, key: String) -> bool:
	var clean_url: String = url.strip_edges().trim_suffix("/")
	var clean_key: String = key.strip_edges()

	if not clean_url.begins_with("https://"):
		return false
	if clean_key.length() <= 12:
		return false

	project_url = clean_url
	publishable_key = clean_key
	return save_runtime_config()


func load_runtime_config() -> bool:
	var cfg := ConfigFile.new()
	var err: int = cfg.load("user://felfel_online.cfg")
	if err != OK:
		return is_configured()

	var saved_url: String = str(cfg.get_value("supabase", "project_url", "")).strip_edges().trim_suffix("/")
	var saved_key: String = str(cfg.get_value("supabase", "publishable_key", "")).strip_edges()

	if saved_url != "":
		project_url = saved_url
	if saved_key != "":
		publishable_key = saved_key

	return is_configured()


func save_runtime_config() -> bool:
	var cfg := ConfigFile.new()
	cfg.set_value("supabase", "project_url", project_url)
	cfg.set_value("supabase", "publishable_key", publishable_key)
	return cfg.save("user://felfel_online.cfg") == OK


func clear_session() -> void:
	access_token = ""
	refresh_token = ""
	user_id = ""
	user_email = ""


func sign_up(email: String, password: String) -> void:
	if not is_configured():
		auth_completed.emit(false, "signup", {}, "Online backend مش متظبط.")
		return

	pending_email = email.strip_edges().to_lower()
	var payload: Dictionary = {
		"email": pending_email,
		"password": password
	}
	_post_json(
		project_url + "/auth/v1/signup",
		payload,
		_base_headers(),
		"signup"
	)


func sign_in(email: String, password: String) -> void:
	if not is_configured():
		auth_completed.emit(false, "login", {}, "Online backend مش متظبط.")
		return

	pending_email = email.strip_edges().to_lower()
	var payload: Dictionary = {
		"email": pending_email,
		"password": password
	}
	_post_json(
		project_url + "/auth/v1/token?grant_type=password",
		payload,
		_base_headers(),
		"login"
	)


func save_cloud(save_data: Dictionary) -> void:
	if not has_session():
		cloud_save_completed.emit(false, "مفيش جلسة Online.")
		return

	var payload: Dictionary = {
		"user_id": user_id,
		"save_data": save_data
	}

	var headers: PackedStringArray = _auth_headers()
	headers.append("Prefer: resolution=merge-duplicates,return=minimal")

	_post_json(
		project_url + "/rest/v1/game_saves?on_conflict=user_id",
		payload,
		headers,
		"cloud_save"
	)


func load_cloud_save() -> void:
	if not has_session():
		cloud_load_completed.emit(false, false, {}, "مفيش جلسة Online.")
		return

	var uid_encoded: String = user_id.uri_encode()
	var url: String = project_url + "/rest/v1/game_saves?select=save_data,updated_at&user_id=eq." + uid_encoded + "&limit=1"
	_get_json(url, _auth_headers(), "cloud_load")


func _base_headers() -> PackedStringArray:
	var headers := PackedStringArray()
	headers.append("apikey: " + publishable_key)
	headers.append("Content-Type: application/json")
	return headers


func _auth_headers() -> PackedStringArray:
	var headers: PackedStringArray = _base_headers()
	headers.append("Authorization: Bearer " + access_token)
	return headers


func _post_json(url: String, payload: Dictionary, headers: PackedStringArray, operation: String) -> void:
	var request := HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_request_completed.bind(request, operation))

	var body: String = JSON.stringify(payload)
	var err: int = request.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		request.queue_free()
		_emit_request_start_error(operation, err)


func _get_json(url: String, headers: PackedStringArray, operation: String) -> void:
	var request := HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_request_completed.bind(request, operation))

	var err: int = request.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		request.queue_free()
		_emit_request_start_error(operation, err)


func _emit_request_start_error(operation: String, err: int) -> void:
	var message: String = "تعذر بدء الاتصال. Error %d" % err
	if operation == "signup" or operation == "login":
		auth_completed.emit(false, operation, {}, message)
	elif operation == "cloud_save":
		cloud_save_completed.emit(false, message)
	else:
		cloud_load_completed.emit(false, false, {}, message)


func _on_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray,
	request: HTTPRequest,
	operation: String
) -> void:
	request.queue_free()

	var body_text: String = body.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(body_text)
	var data: Variant = parsed if parsed != null else {}

	if result != HTTPRequest.RESULT_SUCCESS:
		_emit_operation_error(operation, "مشكلة في الاتصال بالإنترنت.")
		return

	if response_code < 200 or response_code >= 300:
		var message: String = _extract_error_message(data, response_code)
		_emit_operation_error(operation, message)
		return

	if operation == "signup" or operation == "login":
		_handle_auth_success(operation, data)
	elif operation == "cloud_save":
		cloud_save_completed.emit(true, "تم رفع الحفظ للسحابة.")
	elif operation == "cloud_load":
		_handle_cloud_load(data)


func _handle_auth_success(operation: String, data: Variant) -> void:
	if not (data is Dictionary):
		auth_completed.emit(false, operation, {}, "رد تسجيل الدخول غير صالح.")
		return

	var response: Dictionary = data
	var user_variant: Variant = response.get("user", {})
	var user: Dictionary = user_variant if user_variant is Dictionary else {}

	var response_access_token: String = str(response.get("access_token", ""))
	var response_refresh_token: String = str(response.get("refresh_token", ""))
	var response_user_id: String = str(user.get("id", ""))
	var response_email: String = str(user.get("email", pending_email))

	# Sign-up مع Email Confirmation قد يرجع User بدون Session.
	if operation == "signup" and response_access_token == "":
		auth_completed.emit(
			true,
			operation,
			{
				"needs_confirmation": true,
				"email": response_email,
				"user_id": response_user_id
			},
			"الحساب اتعمل. فعّل الإيميل وبعدها اعمل Log In."
		)
		return

	if response_access_token == "" or response_user_id == "":
		auth_completed.emit(false, operation, {}, "الجلسة Online ناقصة.")
		return

	access_token = response_access_token
	refresh_token = response_refresh_token
	user_id = response_user_id
	user_email = response_email

	auth_completed.emit(
		true,
		operation,
		{
			"needs_confirmation": false,
			"email": user_email,
			"user_id": user_id
		},
		"تم تسجيل الدخول Online."
	)


func _handle_cloud_load(data: Variant) -> void:
	if not (data is Array):
		cloud_load_completed.emit(false, false, {}, "رد Cloud Save غير صالح.")
		return

	var rows: Array = data
	if rows.is_empty():
		cloud_load_completed.emit(true, false, {}, "مفيش Cloud Save للحساب ده.")
		return

	var row_variant: Variant = rows[0]
	if not (row_variant is Dictionary):
		cloud_load_completed.emit(false, false, {}, "Cloud Save غير صالح.")
		return

	var row: Dictionary = row_variant
	var save_variant: Variant = row.get("save_data", {})
	if not (save_variant is Dictionary):
		cloud_load_completed.emit(false, false, {}, "بيانات Cloud Save غير صالحة.")
		return

	cloud_load_completed.emit(true, true, save_variant, "تم تحميل Cloud Save.")


func _emit_operation_error(operation: String, message: String) -> void:
	if operation == "signup" or operation == "login":
		auth_completed.emit(false, operation, {}, message)
	elif operation == "cloud_save":
		cloud_save_completed.emit(false, message)
	else:
		cloud_load_completed.emit(false, false, {}, message)


func _extract_error_message(data: Variant, response_code: int) -> String:
	if data is Dictionary:
		var obj: Dictionary = data
		var error_keys: Array[String] = ["msg", "message", "error_description", "error"]
		for key: String in error_keys:
			if obj.has(key):
				var value: Variant = obj[key]
				if value is String and str(value) != "":
					return str(value)

	return "Online request failed (%d)." % response_code
