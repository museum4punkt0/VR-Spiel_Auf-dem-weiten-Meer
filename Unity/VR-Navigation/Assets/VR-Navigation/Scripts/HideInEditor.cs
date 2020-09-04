using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class HideInEditor : MonoBehaviour
{
    [SerializeField] bool hideInEditor = default;
    [SerializeField] bool hideWhilePlaying = default;

    void Awake()
    {
        UpdateState();
    }

    void OnValidate()
    {
        gameObject.SetActive(true);// force awake?!
        UpdateState();
    }

    private void UpdateState()
    {
        if (Application.isPlaying)
        {
            if (hideWhilePlaying)
            {
                gameObject.SetActive(false);
            }
            else
            {
                if (hideInEditor)
                {
                    gameObject.SetActive(true);
                }
            }
        }
        else
        {
            if (Application.isEditor)
            {
                if (hideInEditor)
                {
                    gameObject.SetActive(false);
                }
            }
            else
            {
                if (hideWhilePlaying)
                {
                    gameObject.SetActive(true);
                }
            }
        }
    }
}
