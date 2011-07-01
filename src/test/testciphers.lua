require("aeslua");
local util = require("aeslua.util");

math.randomseed(os.time());

function testCrypto(password, data)
    local modes ={aeslua.ECBMODE, aeslua.CBCMODE, aeslua.OFBMODE, aeslua.CFBMODE};
    local keyLengths =  {aeslua.AES128, aeslua.AES192, aeslua.AES256};  
    for i, mode in ipairs(modes) do
        for j, keyLength in ipairs(keyLengths) do
            print("--");
            cipher = aeslua.encrypt(password, data, keyLength, mode);
            print("Cipher: ", util.toHexString(cipher));
            plain = aeslua.decrypt(password, cipher, keyLength, mode);
            print("Mode: ", mode, " keyLength: ", keyLength, " Plain: ", plain);
            print("--");
        end
    end
end 

testCrypto("sp","hello world!");
testCrypto("longpasswordlongerthant32bytesjustsomelettersmore", "hello world!");
