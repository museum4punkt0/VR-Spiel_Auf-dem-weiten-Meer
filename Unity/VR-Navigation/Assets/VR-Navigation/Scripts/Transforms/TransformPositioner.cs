using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TransformPositioner : MonoBehaviour
{
    public bool lockX, lockY, lockZ;
    public void SetPosition(Vector3 p)
    {
        transform.position = new Vector3(lockX ? transform.position.x : p.x, lockY ? transform.position.y : p.y, lockZ ? transform.position.z : p.z);
    }

    public void SetRotation(Quaternion r)
    {
        transform.rotation = r;
    }

    public void CopyFrom(Transform t)
    {
        SetPosition(t.position);
        SetRotation(t.rotation);
    }
}
