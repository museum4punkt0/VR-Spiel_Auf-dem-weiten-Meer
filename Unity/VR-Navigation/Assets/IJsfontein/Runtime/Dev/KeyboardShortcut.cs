using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class KeyboardShortcut : MonoBehaviour
{
    public KeyCode KeyCode;
    public bool EditorOnly = false;
    public UnityEvent OnKeyPressed;

    void Update()
    {
        if (!EditorOnly || Application.isEditor)
        {
            if (Input.GetKeyDown(KeyCode))
            {
                if (OnKeyPressed != null)
                {
                    OnKeyPressed.Invoke();
                }
            }
        }
    }
}
