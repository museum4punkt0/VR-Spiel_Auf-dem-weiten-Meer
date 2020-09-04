using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;


namespace IJsfontein.AppUpdater
{
    [CustomEditor(typeof(UpdaterSettings))]
    public class UpdaterSettingsEditor : Editor
    {
        override public void OnInspectorGUI()
        {
            DrawDefaultInspector();
            UpdaterSettings settings = (target as UpdaterSettings);
            if (settings.useBasicAuthentication)
            {
                settings.username = EditorGUILayout.TextField("Username", settings.username);
                settings.password = EditorGUILayout.PasswordField("Password", settings.password);
            }

        }

    }

}