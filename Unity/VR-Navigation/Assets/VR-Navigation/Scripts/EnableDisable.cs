using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnableDisable : MonoBehaviour
{
    void OnEnable()
    {
        Debug.Log($"{this} enabled", this);
    }

    void OnDisable()
    {
        Debug.Log($"{this} disabled", this);
    }
}
