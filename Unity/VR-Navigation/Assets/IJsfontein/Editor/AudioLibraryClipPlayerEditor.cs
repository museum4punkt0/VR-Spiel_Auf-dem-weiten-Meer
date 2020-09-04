using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace IJsfontein.Audio
{
    [CustomEditor(typeof(AudioLibraryClipPlayer))]
    public class AudioLibraryClipPlayerEditor : Editor
    {
        override public void OnInspectorGUI()
        {
            AudioLibraryClipPlayer player = (target as AudioLibraryClipPlayer);


            AudioLibrary library = player.Library;
            if (library != null)
            {
                List<string> names = new List<string>();
                List<string> guids = new List<string>();

                names.Add("Select...");
                names.AddRange(library.Clips.Select(e => e.Name).Where(e => e != null));
                guids.AddRange(library.Clips.Select(c => c.Guid).Where(c => c != null));

                if (names.Count > 1)
                {
                    int index = -1;
                    index = guids.IndexOf(player.ClipGuid) + 1;
                    int currentIndex = index;
                    // if (index == 0) // if guid not found, fall back to name
                    // {
                    //     index = names.IndexOf(player.ClipId);
                    // }

                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.PrefixLabel("Clip ID");
                    index = EditorGUILayout.Popup(index, names.ToArray());
                    EditorGUILayout.EndHorizontal();
                    if (currentIndex != index)
                    {
                        Undo.RecordObject(player, "Change Audio Clip");
                        if (index > 0)
                        {
                            // player.ClipId = names[index];
                            player.ClipGuid = guids[index - 1];
                        }
                        else
                        {
                            player.ClipGuid = null;
                        }
                    }
                }
            }
            else
            {
                EditorGUILayout.HelpBox("Set the Audio Library to an existing Audio Library instance.", MessageType.Error);
            }
            DrawDefaultInspector();
        }
    }
}