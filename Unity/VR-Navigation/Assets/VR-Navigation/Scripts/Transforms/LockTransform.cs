using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class LockTransform : MonoBehaviour
{
    [SerializeField] LockOnTransform locked = default;
    [SerializeField] bool lockOnEnable = default;
    [SerializeField] bool lockPosition = default;
    [SerializeField] bool lockRotation = default;

    void OnEnable()
    {
        if (locked && lockOnEnable)
        {
            LockPosition();
            LockRotation();
        }
    }

    public bool LockPosition()
    {
        if (lockPosition)
        {
            locked.PositionLock = transform;
        }
        return lockPosition;
    }

    public bool LockRotation()
    {
        if (lockRotation)
        {
            locked.RotationLock = transform;
        }
        return lockRotation;
    }
}
