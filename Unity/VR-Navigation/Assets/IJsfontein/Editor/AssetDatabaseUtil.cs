using UnityEditor;
using UnityEngine;

namespace IJsfontein
{
    /// <summary>
    /// 
    /// </summary>
    public static class AssetDatabaseUtil
    {
        /// <summary>
        /// Loads a single instance of a subtype of a ScriptableObject asset file.
        /// If multiple files are found the first one found is returned
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="asset"></param>
        /// <returns><code>true</code> if the instance is successfully loaded,
        /// <code>false</code> otherwise.</returns>
        public static bool LoadAsset<T>(out T asset) where T : UnityEngine.Object
        {
            string typeName = typeof(T).FullName;
            string[] assetGUIDs = AssetDatabase.FindAssets("t:" + typeName);
            if (assetGUIDs != null && assetGUIDs.Length > 0)
            {
                if (assetGUIDs.Length > 1)
                {
                    Debug.LogWarning(string.Format("Multiple assets of type {0} found, only the first is used", typeName));
                }

                string path = AssetDatabase.GUIDToAssetPath(assetGUIDs[0]);
                asset = AssetDatabase.LoadAssetAtPath<T>(path);
                if (asset == null)
                {
                    Debug.LogErrorFormat("Failed to obtain {0} from path {1}", typeName, path);
                    return false;
                }

                return true;
            }
            else
            {
                asset = null;
                return false;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="name"></param>
        /// <returns></returns>
        public static T LoadAsset<T>(string name) where T : UnityEngine.Object
        {
            string typeName = typeof(T).FullName;
            string[] assetGUIDs = AssetDatabase.FindAssets(name + " t:" + typeName);
            if (assetGUIDs != null && assetGUIDs.Length > 0)
            {
                if (assetGUIDs.Length > 1)
                {
                    Debug.LogWarning(string.Format("Multiple assets of type {0} named {1} found, only the first is used", typeName, name));
                }

                string path = AssetDatabase.GUIDToAssetPath(assetGUIDs[0]);
                T asset = AssetDatabase.LoadAssetAtPath<T>(path);
                if (asset == null)
                {
                    Debug.LogErrorFormat("Failed to obtain {0} of type {1} from path {2}", name, typeName, path);
                }

                return asset;
            }
            else
            {
                Debug.LogErrorFormat("Asset named {0} not found", name);
                return null;
            }
        }
    }
}
