using System;
using UnityEngine;

namespace IJsfontein.Properties
{
    /// <summary>
    /// Attribute which makes public fields on behaviours read-only in the editor.
    /// Useful for showing values in the editor which are changed at runtime, but
    /// should not be modified manually.
    /// </summary>
    /// <example>
    /// class MyBehaviour : MonoBehaviour
    /// {
    ///     [ReadOnly]
    ///     public float readOnly = 1.0f;
    /// }
    /// </example>
    [AttributeUsage(AttributeTargets.Field, AllowMultiple = false)]
    public class ReadOnlyAttribute : PropertyAttribute
    {
    }
}
