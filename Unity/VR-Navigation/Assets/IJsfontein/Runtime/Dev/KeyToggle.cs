using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

[RequireComponent(typeof(KeyboardShortcut))]
public class KeyToggle : MonoBehaviour
{
    [SerializeField] bool switchedOn;
    public SwitchedEvent OnToggled;

    public void Toggle()
    {
        switchedOn = !switchedOn;
        OnToggled?.Invoke(switchedOn);
    }

    void Start()
    {
        OnToggled?.Invoke(switchedOn);
    }
}

[Serializable]
public class SwitchedEvent : UnityEvent<bool> { }
