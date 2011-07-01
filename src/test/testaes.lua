require("aeslua");
local aes = aeslua.aes;
local util = aeslua.util;

--test vectors

aesplain1 = {0x32, 0x43, 0xf6, 0xa8, 
             0x88, 0x5a, 0x30, 0x8d, 
             0x31, 0x31, 0x98, 0xa2, 
             0xe0, 0x37, 0x07, 0x34};
aesplain2 = {0x00, 0x11, 0x22, 0x33,
             0x44, 0x55, 0x66, 0x77,
             0x88, 0x99, 0xaa, 0xbb,
             0xcc, 0xdd, 0xee, 0xff};
aes128key1 = {0x2b,0x7e,0x15,0x16,
              0x28,0xae,0xd2,0xa6,
              0xab,0xf7,0x15,0x88,
              0x09,0xcf,0x4f,0x3c};
aes128key2 = {0x00, 0x01, 0x02, 0x03,
              0x04, 0x05, 0x06, 0x07,
              0x08, 0x09, 0x0a, 0x0b,
              0x0c, 0x0d, 0x0e, 0x0f};
aes192key1 = {0x8e,0x73,0xb0,0xf7,
              0xda,0x0e,0x64,0x52,
              0xc8,0x10,0xf3,0x2b,
              0x80,0x90,0x79,0xe5,
              0x62,0xf8,0xea,0xd2,
              0x52,0x2c,0x6b,0x7b};
aes192key2 = {0x00, 0x01, 0x02, 0x03,
              0x04, 0x05, 0x06, 0x07,
              0x08, 0x09, 0x0a, 0x0b,
              0x0c, 0x0d, 0x0e, 0x0f,
              0x10, 0x11, 0x12, 0x13,
              0x14, 0x15, 0x16, 0x17};
aes256key1 = {0x60,0x3d,0xeb,0x10,
              0x15,0xca,0x71,0xbe,
              0x2b,0x73,0xae,0xf0,
              0x85,0x7d,0x77,0x81,
              0x1f,0x35,0x2c,0x07,
              0x3b,0x61,0x08,0xd7,
              0x2d,0x98,0x10,0xa3,
              0x09,0x14,0xdf,0xf4};
aes256key2 = {0x00, 0x01, 0x02, 0x03,
              0x04, 0x05, 0x06, 0x07,
              0x08, 0x09, 0x0a, 0x0b,
              0x0c, 0x0d, 0x0e, 0x0f,
              0x10, 0x11, 0x12, 0x13,
              0x14, 0x15, 0x16, 0x17,
              0x18, 0x19, 0x1a, 0x1b,
              0x1c, 0x1d, 0x1e, 0x1f};


function printSBox() 
    print("sbox");
    for i=0,255 do
	    print(string.format("%x: %x", i, aes.SBox[i]));
    end

    print("inverse sbox");
    for i=0,255 do
	    print(string.format("%x: %x", i, aes.iSBox[i]));
    end
end

function testRound()
    state = {0x19, 0x3d, 0xe3,0xbe, 
            0xa0, 0xf4, 0xe2, 0x2b,
            0x9a, 0xc6, 0x8d, 0x2a,
            0xe9, 0xf8, 0x48, 0x08};

    printState(state);
    aes.subBytes(state);
    printState(state);
    aes.shiftRows(state);
    printState(state);
    aes.mixColumn(state);
    printState(state);
end


function printKeyExpansion(key)
    keySchedule = aes.expandEncryptionKey(key);
    print("ENCRYPT");
    for i=0,#keySchedule do
       print(string.format("%d[%d]= %x",keySchedule[aes.ROUNDS],i,keySchedule[i]));
    end

    keySchedule = aes.expandDecryptionKey(key);
    print("DECRYPT");
    for i=0,#keySchedule do
        print(string.format("%d[%d]= %x",keySchedule[aes.ROUNDS],i,keySchedule[i]));
    end
end

function testKeyExpansion()
    printKeyExpansion(aes128key1);
    
    printKeyExpansion(aes192key1);
    
    printKeyExpansion(aes256key1);
end

function AESEncrypt(key, plain)
    keySched = aes.expandEncryptionKey(key); 
    cipher = aes.encrypt(keySched, plain); 
    keySched = aes.expandDecryptionKey(key);
    decrypted = aes.decrypt(keySched,cipher);
    
    return {key, plain, cipher, decrypted};
end

function printResult(result)
    print("Key:");
    print(util.toHexString(result[1]));
    print("Plaintext:");
    print(util.toHexString(result[2]));
    print("Ciphertext:");
    print(util.toHexString(result[3]));
    print("Decrypted:");
    print(util.toHexString(result[4])); 
end

function testResult(result)
    local plaintext = result[2];
    local decrypt = result[4]

    for i=1,16 do
        if (decrypt[i] ~= plaintext[i]) then
            return false;
        end
    end
    
    return true;
end

function testEncrypt()
    local result1 = AESEncrypt(aes128key2, aesplain2);
    printResult(result1);
   
    result1 = AESEncrypt(aes192key2, aesplain2);
    printResult(result1);
    
    result1 = AESEncrypt(aes256key2, aesplain2);
    printResult(result1);
end


function getRandomBits(bits)
    local result = {};

    for i=1,bits/8 do
        result[i] = math.random(0,255);
    end
    
    return result;
end

function testnAES(n)
    math.randomseed(os.time());
    
    for x=1,n do
        key = getRandomBits(128);
        plaintext = getRandomBits(128);

        local result = AESEncrypt(key, plaintext);
        if (not testResult(result)) then
            print("ENCRYPTION/DECRYPTION ERROR:");
            printResult(result);
            return false;
        end
    end
    
   	return true;
end

--testKeyExpansion();
--testEncrypt();
print("Testing 1000 random en-/decryptions...");
if (testnAES(1000)) then
	print("ok.");
end


