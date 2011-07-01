-- Usage: filedecrypt.lua [file] [password] > decryptedfile
--
-- Decrypts everything from [file] and writes decrypted data to stdout.
-- Do not use for real decryption, because the password is easily viewable 
-- while decrypting.
--
require("aeslua");

if (#arg ~= 2) then
	print("Usage: filedecrypt.lua [file] [password] > decryptedfile\n");
	print("Do not use for real decryption, because the password is easily viewable while decrypting.");
	return 1;
end

local file = assert(io.open(arg[1], "r"));
local cipher = file:read("*all");
local plain = aeslua.decrypt(arg[2], cipher);
if (plain == nil) then
	print("Invalid password.");
else
	io.write(plain);
end
file:close();