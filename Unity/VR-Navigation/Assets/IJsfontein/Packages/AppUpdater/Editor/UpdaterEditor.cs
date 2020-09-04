using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace IJsfontein.AppUpdater
{
    [CustomEditor(typeof(Updater))]
    public class UpdaterEditor : Editor
    {
        override public void OnInspectorGUI()
        {
#if UNITY_2017_1_OR_NEWER
            DrawDefaultInspector();
            Updater updater = (target as Updater);
            if (updater.currentVersion == null)
            {
                if (!VersionAssetExists())
                {
                    EditorGUILayout.HelpBox("Please create a Version asset!", MessageType.Warning);
                }
            }

#else
        EditorGUILayout.HelpBox("This component needs Unity 2017.1 or newer.", MessageType.Warning);
#endif
        }

        public bool VersionAssetExists()
        {
            string typeName = typeof(Version).FullName;
            string[] assetGUIDs = AssetDatabase.FindAssets("t:" + typeName);
            if (assetGUIDs != null && assetGUIDs.Length > 0)
            {
                return true;
            }
            return false;
        }
    }

}