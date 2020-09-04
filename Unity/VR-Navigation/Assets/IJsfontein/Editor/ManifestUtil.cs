using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace IJsfontein.Dev
{
    public class ManifestUtil
    {
        [MenuItem("Tools/IJsfontein/Reset Manifest Locks")]
        public static void ResetManifest()
        {
            string manifestPath = Path.GetFullPath(Path.Combine(Application.dataPath, "../Packages/manifest.json"));
            Debug.Log($"{manifestPath}");
            if (File.Exists(manifestPath))
            {
                List<string> lines = new List<string>(File.ReadAllLines(manifestPath));
                int l = lines.IndexOf("  \"lock\": {");
                // Debug.Log($"lock line {l}");
                int e = lines.Count - 2;

                int startLine = (l - 1);
                int count = e - l + 1;
                // Debug.Log($"will delete line {startLine + 1} to {startLine + count + 1}");
                lines.RemoveRange(startLine, count);
                File.WriteAllLines(manifestPath, lines);
                AssetDatabase.Refresh();
            }
        }
    }
}