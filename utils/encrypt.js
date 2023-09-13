const ethcrypto = require("eth-crypto");
const readline = require("readline");

const main = async () => {
  const DONPublicKey =
    "a30264e813edc9927f73e036b7885ee25445b836979cb00ef112bc644bd16de2db866fa74648438b34f52bb196ffa386992e94e0a3dc6913cee52e2e98f1619c";
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  const url = await new Promise((resolve) => {
    rl.question("Enter Gist URL: ", (answer) => {
      resolve(answer);
    });
  });

  const secrets = "0x" + (await encrypt(DONPublicKey, url));
  console.log("Encrypted secrets: \n\n" + secrets + "\n");
  rl.close();
};

const encrypt = async (readerPublicKey, message) => {
  const encrypted = await ethcrypto.encryptWithPublicKey(
    readerPublicKey,
    message
  );
  return ethcrypto.cipher.stringify(encrypted);
};

main().catch(console.error);
