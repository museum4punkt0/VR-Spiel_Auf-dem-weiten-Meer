using System;
using System.IO;
using UnityEngine;

[CreateAssetMenu]
[Serializable]
public class Settings : ScriptableObject
{
    [SerializeField] float gameDurationMinutes = 15.0f;
    [SerializeField] float endScreenDurationMinutes = 1;

    static string path { get => Path.Combine(IJsfontein.MyDocumentsPath.AppFolder, "settings.json"); }
    public int GameDurationSeconds => (int)(gameDurationMinutes * 60);
    public int EndScreenDurationSeconds => (int)(endScreenDurationMinutes * 60);

    void OnEnable()
    {
        Load();
    }

    public void Load()
    {
        if (File.Exists(path))
        {
            Debug.Log($"{this}:Loading from {path}", this);
            try
            {
                string json = File.ReadAllText(path);
                JsonUtility.FromJsonOverwrite(json, this);
            }
            catch (Exception e)
            {
                Debug.LogError($"{this}: Json parsing failed: {e.Message}", this);
            }
        }
        Save(); // creates file with loaded settings, and defaults for any missing values (or when not available at all)
    }

    [ContextMenu("Save to JSON")]
    public void Save()
    {
        string json = JsonUtility.ToJson(this, prettyPrint: true);
        Debug.Log($"{this}:Save {json} to {path}", this);
        File.WriteAllText(path, json);
    }

    [ContextMenu("Open JSON file")]
    public void OpenFile()
    {
        string url = $"file://{path}";
        Debug.Log($"{this}: opening file at {url}", this);
        Application.OpenURL(url);
    }
}
