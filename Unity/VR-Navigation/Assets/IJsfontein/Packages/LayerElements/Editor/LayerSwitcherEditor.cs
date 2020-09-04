using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

namespace IJsfontein.LayerElements
{
    [CustomEditor(typeof(ElementsLayerSwitcher))]
    public class LayerSwitcherEditor : Editor
    {
        private const string DEFAULTENUMFILENAME = "GeneratedLayerNames.cs";

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            ElementsLayerSwitcher switcher = target as ElementsLayerSwitcher;
            ElementsLayer[] layers = switcher.Layers;
            int currentLayer = switcher.SelectedLayer;

            string[] names = layers.Select(l => l.Name).ToArray();
            for (int i = names.Length; --i >= 0;)
            {
                if (string.IsNullOrWhiteSpace(names[i]))
                {
                    names[i] = string.Format("Element {0}", i);
                }
            }
            int selected = EditorGUILayout.Popup(GUIContent.none, currentLayer, names);
            if (GUILayout.Button("Refresh") || currentLayer != selected)
            {
                ActivateLayer(switcher, selected);
            }
            if (GUILayout.Button("All off"))
            {
                ActivateLayer(switcher, -1);
            }

            EditorGUILayout.Separator();

            // Draw only the fields we want to expose here
            EditorGUILayout.PropertyField(serializedObject.FindProperty("layers"), true);

            if (names.Distinct().Count() != layers.Length)
            {
                EditorGUILayout.HelpBox("Duplicate layer names are not supported", MessageType.Warning);
            }

            if (!Application.isPlaying) // only show enum generator buttons when not playing!
            {
                EditorGUILayout.Space();

                switcher.showEnumSection = EditorGUILayout.Foldout(switcher.showEnumSection, "Enum generation");
                if (switcher.showEnumSection)
                {
                    EditorGUILayout.PropertyField(serializedObject.FindProperty("enumFile"), new GUIContent("File"));
                    EditorGUILayout.PropertyField(serializedObject.FindProperty("enumNamespaceOverride"), new GUIContent("Namespace"));

                    if (switcher.enumFile != null)
                    {
                        int instanceID = switcher.enumFile.GetInstanceID();
                        string assetPath = AssetDatabase.GetAssetPath(instanceID);

                        if (switcher.enumFile.text.StartsWith(LayerEnumGenerator.HEADER))
                        {
                            if (GUILayout.Button("Update enum"))
                            {
                                LayerEnumGenerator.GenerateEnumFile(names, assetPath, switcher.enumNamespaceOverride);
                            }
                        }
                        else
                        {
                            EditorGUILayout.HelpBox("Will not overwrite a file that was not generated first", MessageType.Error);
                        }
                    }
                    else
                    {
                        string assetPath = Path.Combine("Assets", DEFAULTENUMFILENAME);
                        if (!File.Exists(assetPath))
                        {
                            if (GUILayout.Button("Generate enum"))
                            {
                                LayerEnumGenerator.GenerateEnumFile(names, assetPath, switcher.enumNamespaceOverride);
                                switcher.enumFile = AssetDatabase.LoadAssetAtPath<MonoScript>(assetPath);
                            }
                        }
                        else
                        {
                            EditorGUILayout.HelpBox("Can't generate an enum file because one already exists at the default location", MessageType.Warning);
                        }
                    }
                }
            }
            serializedObject.ApplyModifiedProperties();
        }

        public void OnSceneGUI()
        {
            Event e = Event.current;
            Handles.BeginGUI();
            GUILayout.BeginArea(new Rect(10, 10, 150, 80));

            EditorGUILayout.BeginVertical();

            GUILayout.Label(target.name + " Layers");
            OnInspectorGUI();
            EditorGUILayout.EndVertical();
            GUILayout.EndArea();

            Handles.EndGUI();
        }

        private void ActivateLayer(ElementsLayerSwitcher switcher, int newLayer)
        {
            Undo.RecordObject(switcher, "Changed Active Layer");
            switcher.Refresh();
            switcher.ActivateLayer(newLayer);
            Undo.undoRedoPerformed += OnUndo;
        }

        private void OnUndo()
        {
            ElementsLayerSwitcher switcher = target as ElementsLayerSwitcher;
            switcher.ActivateLayer(switcher.SelectedLayer);
        }
    }

    internal class LayerEnumGenerator
    {
        public const string HEADER = "// This is an autogenerated Layer Switcher enum file. You can move it or rename it, but do not edit!";
        private const string DEFAULTNAMESPACE = "IJsfontein.LayerElements";
        private const string FORMAT =
@"{0}
namespace {1}
{{
    public enum LayerName
    {{
        {2}
    }}
}}";

        public static void GenerateEnumFile(string[] layerNames, string assetPath, string enumNamespace)
        {
            if (string.IsNullOrEmpty(enumNamespace) || string.IsNullOrWhiteSpace(enumNamespace))
            {
                enumNamespace = DEFAULTNAMESPACE;
            }

            string enums = string.Join(",\n        ", layerNames.Select(v => LayerNameToEnumName(v)));
            string fileContents = string.Format(FORMAT, HEADER, enumNamespace, enums);

            File.WriteAllText(assetPath, fileContents);
            AssetDatabase.Refresh();
        }

        private static string LayerNameToEnumName(string name)
        {
            char[] chars = name.ToCharArray();
            List<char> validChars = chars.Where(c => char.IsLetterOrDigit(c)).ToList();
            if (validChars.Count == 0 || !char.IsLetter(validChars[0]))
            {
                validChars.Insert(0, '_');
            }
            string fix = string.Join("", validChars);

            return fix;
        }
    }
}