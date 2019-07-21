using System;
using System.Security.Cryptography;
using System.Text;

namespace GoldenEye.Shared.Core.Utils.Cryptography
{
    /// <summary>
    /// Class to help encrypt/decrypt password.
    /// </summary>
    public class Encryption
    {
        /// <summary>
        /// Private encryption key.
        /// </summary>
        private const string Key = "qwe123ASD!@#zxc";

        /// <summary>
        /// Encrypt string.
        /// </summary>
        /// <param name="message">Message to encrypt.</param>
        /// <returns></returns>
        public static string EncryptString(string message)
        {
            byte[] results;
            var utf8 = new UTF8Encoding();

            // Step 1. We hash the passphrase using MD5
            // We use the MD5 hash generator as the result is a 128 bit byte array
            // which is a valid length for the TripleDES encoder we use below

            using (var hashProvider = MD5.Create())
            {
                byte[] tdesKey = hashProvider.ComputeHash(utf8.GetBytes(Key));

                // Step 2. Create a new TripleDESCryptoServiceProvider object
                using (var tdesAlgorithm = TripleDES.Create())
                {
                    tdesAlgorithm.Key = tdesKey;
                    tdesAlgorithm.Mode = CipherMode.ECB;
                    tdesAlgorithm.Padding = PaddingMode.PKCS7;
                    // Step 3. Setup the encoder

                    // Step 4. Convert the message string to a byte[]
                    byte[] dataToEncrypt = utf8.GetBytes(message);

                    // Step 5. Attempt to encrypt the string
                    ICryptoTransform encryptor = tdesAlgorithm.CreateEncryptor();
                    results = encryptor.TransformFinalBlock(dataToEncrypt, 0, dataToEncrypt.Length);

                    // Step 6. Return the encrypted string as a base64 encoded string
                    return Convert.ToBase64String(results);
                }
            }
        }

        /// <summary>
        /// Decrypt string
        /// </summary>
        /// <param name="message">Message to decryption.</param>
        /// <returns></returns>
        public static string DecryptString(string message)
        {
            if (string.IsNullOrEmpty(message))
                return string.Empty;

            byte[] results;
            var utf8 = new UTF8Encoding();

            // Step 1. We hash the passphrase using MD5
            // We use the MD5 hash generator as the result is a 128 bit byte array
            // which is a valid length for the TripleDES encoder we use below

            using (var hashProvider = MD5.Create())
            {
                byte[] tdesKey = hashProvider.ComputeHash(utf8.GetBytes(Key));

                // Step 2. Create a new TripleDESCryptoServiceProvider object
                using (var tdesAlgorithm = TripleDES.Create())
                {
                    tdesAlgorithm.Key = tdesKey;
                    tdesAlgorithm.Mode = CipherMode.ECB;
                    tdesAlgorithm.Padding = PaddingMode.PKCS7;

                    // Step 3. Setup the decoder

                    // Step 4. Convert the message string to a byte[]
                    byte[] dataToDecrypt = Convert.FromBase64String(message);

                    // Step 5. Attempt to decrypt the string
                    ICryptoTransform decryptor = tdesAlgorithm.CreateDecryptor();
                    results = decryptor.TransformFinalBlock(dataToDecrypt, 0, dataToDecrypt.Length);
                }
            }

            // Step 6. Return the decrypted string in UTF8 format
            return utf8.GetString(results);
        }
    }
}
