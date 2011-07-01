-- Usage: fileencrypt.lua [file] [password] > encryptedfile
--
-- Encrypts everything from [file] and writes encrypted data to stdout.
-- Do not use for real encryption, because the password is easily viewable 
-- while encrypting.
--
require("aeslua");

if (#arg ~= 2) then
	print("Usage: fileencrypt.lua [file] [password] > encryptedfile\n");
	print("Do not use for real encryption, because the password is easily viewable while encrypting.");
	return 1;
end

local file = assert(io.open(arg[1], "r"));
local text = file:read("*all");
local cipher = aeslua.encrypt(arg[2], text);
io.write(cipher);
file:close();
