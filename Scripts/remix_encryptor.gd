extends Node


const ENCRYPTION_KEY = "Xy6wCxuz5=3RP?WmxZ9p:[gjV:~mH62r"
const FILE_HEADER = "REMIXENC0"
const HEADER_SIZE = 9


func pkcs7_pad(data: PackedByteArray, block_size: int = 16) -> PackedByteArray:
	var pad_len = block_size - (data.size() % block_size)
	for i in range(pad_len):
		data.append(pad_len)
	return data

func pkcs7_unpad(data: PackedByteArray) -> PackedByteArray:
	if data.size() == 0:
		return data
	var pad_len = data[data.size() - 1]
	return data.slice(0, data.size() - pad_len)


func encrypt_remix_file(input_path: String, output_path: String) -> bool:
	var file_data = FileAccess.get_file_as_bytes(input_path)
	if file_data.is_empty():
		push_error("输入文件为空或不存在: %s" % input_path)
		return false

	var key_buf = ENCRYPTION_KEY.to_utf8_buffer()
	if key_buf.size() != 32:
		push_error("加密密钥长度必须为32字节")
		return false

	file_data = pkcs7_pad(file_data, 16)
	print("📏 填充后数据大小: %d 字节" % file_data.size())

	var aes = AESContext.new()
	aes.start(AESContext.MODE_ECB_ENCRYPT, key_buf)
	var encrypted = aes.update(file_data)
	aes.finish()

	print("🔐 加密后数据大小: %d 字节" % encrypted.size())


	if encrypted.size() % 16 != 0:
		push_error("❌ 加密后数据长度不是16的倍数: %d 字节" % encrypted.size())
		return false

	print("✅ 加密数据长度验证通过")


	var final_data = FILE_HEADER.to_ascii_buffer()
	final_data.append_array(encrypted)

	var file = FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_error("保存加密文件失败: %s" % output_path)
		return false
	file.store_buffer(final_data)
	file.close()
	return true


func decrypt_remix_file(input_path: String, output_path: String) -> bool:
	print("🔓 开始解密文件: %s" % input_path)

	var file_data = FileAccess.get_file_as_bytes(input_path)
	if file_data.is_empty():
		push_error("❌ 输入文件为空或不存在: %s" % input_path)
		return false

	if file_data.size() <= HEADER_SIZE:
		push_error("❌ 文件太小，不是有效的加密Remix文件: %s (大小: %d 字节)" % [input_path, file_data.size()])
		return false

	print("📁 文件大小: %d 字节" % file_data.size())


	var header = file_data.slice(0, HEADER_SIZE).get_string_from_ascii()
	print("🔍 检测到文件头: '%s'" % header)

	if header != FILE_HEADER:
		push_error("❌ 文件头不正确，可能不是加密Remix文件: '%s' != '%s'" % [header, FILE_HEADER])
		return false

	var encrypted = file_data.slice(HEADER_SIZE, file_data.size())
	print("🔐 加密数据大小: %d 字节" % encrypted.size())


	if encrypted.size() % 16 != 0:
		push_error("❌ 加密数据长度不是16的倍数: %d 字节 (需要是16的倍数)" % [encrypted.size()])
		print("💡 这可能意味着:")
		print("   1. 文件在加密过程中被损坏")
		print("   2. 文件不是用正确的加密器加密的")
		print("   3. 文件头检测有误")
		return false

	print("✅ 加密数据长度验证通过 (16字节对齐)")

	var key_buf = ENCRYPTION_KEY.to_utf8_buffer()
	if key_buf.size() != 32:
		push_error("❌ 解密密钥长度必须为32字节，当前: %d" % key_buf.size())
		return false

	print("🔑 开始AES解密...")
	var aes = AESContext.new()
	var result = aes.start(AESContext.MODE_ECB_DECRYPT, key_buf)
	if result != OK:
		push_error("❌ AES上下文启动失败: %d" % result)
		return false

	var decrypted = aes.update(encrypted)
	if decrypted.is_empty():
		push_error("❌ AES解密更新失败")
		print("💡 可能的原因:")
		print("   1. 加密数据格式不正确")
		print("   2. 密钥不匹配")
		print("   3. 数据已损坏")
		return false

	aes.finish()
	print("✅ AES解密完成，数据大小: %d 字节" % decrypted.size())


	decrypted = pkcs7_unpad(decrypted)
	print("📏 移除填充后数据大小: %d 字节" % decrypted.size())

	var file = FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_error("❌ 保存解密文件失败: %s" % output_path)
		return false

	file.store_buffer(decrypted)
	file.close()

	print("✅ 解密文件保存成功: %s" % output_path)
	return true


func decrypt_remix_file_to_memory(input_path: String) -> PackedByteArray:
	print("🔓 开始内存解密文件: %s" % input_path)

	var file_data = FileAccess.get_file_as_bytes(input_path)
	if file_data.is_empty():
		push_error("❌ 输入文件为空或不存在: %s" % input_path)
		return PackedByteArray()

	if file_data.size() <= HEADER_SIZE:
		push_error("❌ 文件太小，不是有效的加密Remix文件: %s (大小: %d 字节)" % [input_path, file_data.size()])
		return PackedByteArray()

	print("📁 文件大小: %d 字节" % file_data.size())


	var header = file_data.slice(0, HEADER_SIZE).get_string_from_ascii()
	print("🔍 检测到文件头: '%s'" % header)

	if header != FILE_HEADER:
		push_error("❌ 文件头不正确，可能不是加密Remix文件: '%s' != '%s'" % [header, FILE_HEADER])
		return PackedByteArray()

	var encrypted = file_data.slice(HEADER_SIZE, file_data.size())
	print("🔐 加密数据大小: %d 字节" % encrypted.size())


	if encrypted.size() % 16 != 0:
		push_error("❌ 加密数据长度不是16的倍数: %d 字节 (需要是16的倍数)" % [encrypted.size()])
		print("💡 这可能意味着:")
		print("   1. 文件在加密过程中被损坏")
		print("   2. 文件不是用正确的加密器加密的")
		print("   3. 文件头检测有误")
		return PackedByteArray()

	print("✅ 加密数据长度验证通过 (16字节对齐)")

	var key_buf = ENCRYPTION_KEY.to_utf8_buffer()
	if key_buf.size() != 32:
		push_error("❌ 解密密钥长度必须为32字节，当前: %d" % key_buf.size())
		return PackedByteArray()

	print("🔑 开始AES解密...")
	var aes = AESContext.new()
	var result = aes.start(AESContext.MODE_ECB_DECRYPT, key_buf)
	if result != OK:
		push_error("❌ AES上下文启动失败: %d" % result)
		return PackedByteArray()

	var decrypted = aes.update(encrypted)
	if decrypted.is_empty():
		push_error("❌ AES解密更新失败")
		print("💡 可能的原因:")
		print("   1. 加密数据格式不正确")
		print("   2. 密钥不匹配")
		print("   3. 数据已损坏")
		return PackedByteArray()

	aes.finish()
	print("✅ AES解密完成，数据大小: %d 字节" % decrypted.size())


	decrypted = pkcs7_unpad(decrypted)
	print("📏 移除填充后数据大小: %d 字节" % decrypted.size())
	print("✅ 内存解密完成，无需创建临时文件")

	return decrypted

const IMG_KEY = "Xy6wCxuz5=3RP?WmxZ9p:[gjV:~mH62r"
const IMG_ENCRYPTED_PREFIX = "ENCRYPTEDIMG"

func encrypt_img(img_data: PackedByteArray) -> PackedByteArray:
	var key_buf = IMG_KEY.to_utf8_buffer()
	if key_buf.size() != 32:
		push_error("img加密密钥长度必须为32字节")
		return img_data
	var aes = AESContext.new()
	aes.start(AESContext.MODE_ECB_ENCRYPT, key_buf)
	img_data = pkcs7_pad(img_data, 16)
	var encrypted = aes.update(img_data)
	aes.finish()
	var final_img = IMG_ENCRYPTED_PREFIX.to_ascii_buffer()
	final_img.append_array(encrypted)
	return final_img

func decrypt_img(encrypted_img: PackedByteArray) -> PackedByteArray:
	var prefix_buf = IMG_ENCRYPTED_PREFIX.to_ascii_buffer()
	if encrypted_img.size() < prefix_buf.size():
		return encrypted_img
	var is_encrypted = true
	for i in range(prefix_buf.size()):
		if encrypted_img[i] != prefix_buf[i]:
			is_encrypted = false
			break
	if !is_encrypted:
		return encrypted_img
	var key_buf = IMG_KEY.to_utf8_buffer()
	if key_buf.size() != 32:
		push_error("img解密密钥长度必须为32字节")
		return encrypted_img
	var aes = AESContext.new()
	aes.start(AESContext.MODE_ECB_DECRYPT, key_buf)
	var encrypted = encrypted_img.slice(prefix_buf.size(), encrypted_img.size())
	var decrypted = aes.update(encrypted)
	aes.finish()
	decrypted = pkcs7_unpad(decrypted)
	return decrypted
