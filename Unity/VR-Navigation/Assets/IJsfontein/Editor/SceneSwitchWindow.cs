// --------------------------------
// Based on original code by
// <copyright file="SceneSwitchWindow.cs" company="Rumor Games">
//     Copyright (C) Rumor Games, LLC.  All rights reserved.
// </copyright>
// --------------------------------

using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace IJsfontein
{
    public class SceneSwitchWindow : EditorWindow
    {
        /// <summary>
        /// Tracks scroll position.
        /// </summary>
        private Vector2 scrollPos;

        /// <summary>
        /// Initialize window state.
        /// </summary>
        [MenuItem("Window/Scene Utility")]
        internal static void Init()
        {
            // EditorWindow.GetWindow() will return the open instance of the specified window or create a new
            // instance if it can't find one. The second parameter is a flag for creating the window as a
            // Utility window; Utility windows cannot be docked like the Scene and Game view windows.
            GetWindow(typeof(SceneSwitchWindow), false, "Scene Utility");
        }

        /// <summary>
        /// Called on GUI events.
        /// </summary>
        internal void OnGUI()
        {
            EditorGUILayout.BeginVertical();
            this.scrollPos = EditorGUILayout.BeginScrollView(this.scrollPos, false, false);

            GUILayout.Label(string.Format("Scenes In Build Settings ({0} opened)", EditorSceneManager.sceneCount), EditorStyles.boldLabel);
            for (int i = 0; i < EditorBuildSettings.scenes.Length; i++)
            {
                EditorBuildSettingsScene buildSettingsScene = EditorBuildSettings.scenes[i];
                string sceneName = Path.GetFileNameWithoutExtension(buildSettingsScene.path);
                if (!buildSettingsScene.enabled)
                {
                    sceneName += " (disabled)";
                }
                EditorGUILayout.BeginHorizontal();
                {
                    using (new EditorGUI.DisabledScope(IsSceneOpen(buildSettingsScene)))
                    {
                        GUIContent content = new GUIContent(sceneName, AssetPreview.GetMiniTypeThumbnail(typeof(SceneAsset)));
                        GUIStyle style = new GUIStyle(GUI.skin.GetStyle("Button"))
                        {
                            alignment = TextAnchor.MiddleLeft,
                            stretchWidth = true,
                            fixedHeight = 25
                        };
                        bool pressed = GUILayout.Button(content, style);
                        if (pressed)
                        {
                            if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
                            {
                                EditorSceneManager.OpenScene(buildSettingsScene.path);
                            }
                        }
                    }
                }
                if (!IsSceneOpen(buildSettingsScene))
                {
                    GUIContent content = new GUIContent("Add", "Adds the scene to the current open ones");
                    GUIStyle style = new GUIStyle(GUI.skin.GetStyle("Button"))
                    {
                        alignment = TextAnchor.MiddleLeft,
                        fixedWidth = 60,
                        fixedHeight = 25
                    };
                    bool pressed = GUILayout.Button(content, style);
                    if (pressed)
                    {
                        EditorSceneManager.OpenScene(buildSettingsScene.path, OpenSceneMode.Additive);
                    }
                }
                else if (EditorSceneManager.sceneCount > 1)
                {
                    GUIContent content = new GUIContent("Remove", "Unloads and removes the scene");
                    GUIStyle style = new GUIStyle(GUI.skin.GetStyle("Button"))
                    {
                        alignment = TextAnchor.MiddleLeft,
                        fixedWidth = 60,
                        fixedHeight = 25
                    };
                    bool pressed = GUILayout.Button(content, style);
                    if (pressed)
                    {
                        Scene scene = FromBuildSettingsScene(buildSettingsScene);
                        if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
                        {
                            EditorSceneManager.CloseScene(scene, true);
                        }
                    }
                }

                EditorGUILayout.EndHorizontal();
            }

            EditorGUILayout.EndScrollView();
            EditorGUILayout.EndVertical();
        }

        private static bool IsSceneOpen(EditorBuildSettingsScene scene)
        {
            Scene loadedScene = FromBuildSettingsScene(scene);
            return loadedScene.isLoaded;
        }

        private static Scene FromBuildSettingsScene(EditorBuildSettingsScene scene)
        {
            for (int i = 0; i < EditorSceneManager.sceneCount; i++)
            {
                Scene loadedScene = EditorSceneManager.GetSceneAt(i);
                if (loadedScene.path == scene.path)
                {
                    return loadedScene;
                }
            }
            return default;
        }
    }
}