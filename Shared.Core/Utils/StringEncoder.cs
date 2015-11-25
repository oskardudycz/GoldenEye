using System;
using System.IO;
using System.Security.Cryptography;

namespace Shared.Core.Utils
{
    public class StringEncoder
    {
        private static readonly byte[] Key = { 205, 163, 26, 96, 25, 54, 203, 135, 68, 99, 64, 194, 174, 27, 23, 245, 228, 233, 38, 68, 189, 65, 146, 16, 229, 101, 163, 208, 169, 94, 250, 135 };
        private static readonly byte[] IV = { 213, 201, 113, 130, 215, 195, 104, 176, 82, 225, 123, 47, 217, 72, 245, 32 };
        private const int KeySize = 256;


        /// <summary>
        /// Zaszyfrowanie stringa przy uzyciu AES.
        /// </summary>
        /// <param name="data">Tekst do zaszyfrowania.</param>
        /// <returns>Zaszyfrowany tekst.</returns>
        public static string Encrypt(string data)
        {
            MemoryStream ms = null;
            StreamWriter sw = null;
            CryptoStream cs = null;
            AesManaged aes = null;

            try
            {
                aes = new AesManaged
                {
                    IV = IV,
                    Key = Key,
                    KeySize = KeySize
                };

                ms = new MemoryStream();

                //utworzenie cryptoTransform
                var aesTransform = aes.CreateEncryptor(Key, IV);

                cs = new CryptoStream(ms, aesTransform, CryptoStreamMode.Write);

                //zapis do strumienia
                sw = new StreamWriter(cs);

                //zapis danych
                sw.Write(data);
            }
            catch (Exception)
            {
            }
            finally
            {
                //czyszczenie
                if (sw != null)
                    sw.Close();
                if (cs != null)
                    cs.Close();
                if (ms != null)
                    ms.Close();
                if (aes != null)
                    aes.Clear();
            }

            return Convert.ToBase64String(ms.ToArray());
        }
    }
}