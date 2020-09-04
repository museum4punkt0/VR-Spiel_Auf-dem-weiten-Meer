using System;
using System.IO;
using UnityEngine;

namespace IJsfontein
{
    public static class MyDocumentsPath
    {
        /// <summary>
        /// returns the Application.persistentDataPath except on desktop platforms, where it returns a folder in the User's Documents folder with the name of the application.
        /// </summary>
        public static string AppFolder
        {
            get
            {
                string path = Application.persistentDataPath;

                if (!Application.isEditor)
                {
                    if (!Application.isMobilePlatform)
                    {
                        path = System.Environment.GetFolderPath(System.Environment.SpecialFolder.MyDocuments) + "/" + Application.productName;
                        if (!Directory.Exists(path))
                        {
                            Directory.CreateDirectory(path);
                        }
                    }
                }

                return path;
            }
        }
    }
}
