using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEditor;
using UnityEngine;

namespace IJsfontein.Properties
{
    /// <summary>
    /// 
    /// </summary>
    /// <remarks>
    /// See http://www.gamedev.net/blog/1918/entry-2261911-unity-editor-data-entry-20/
    /// See http://forum.unity3d.com/threads/streamlined-data-entry.395719/
    /// </remarks>
    [CustomPropertyDrawer(typeof(ConditionalAttribute))]
    public class ConditionalPropertyDrawer : PropertyDrawer
    {
        /// <summary>
        /// 
        /// </summary>
        private ConditionalAttribute Attribute
        {
            get { return (ConditionalAttribute)attribute; }
        }

        /// <inheritdoc />
        public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
        {
            if (!Attribute.Show)
            {
                return -2.0f;
            }

            // Check for multiline or textarea attributes
            object[] customAttributes = fieldInfo.GetCustomAttributes(false);
            for (int i = 0; i < customAttributes.Length; i++)
            {
                if (customAttributes[i] is MultilineAttribute)
                {
                    return (float)((!EditorGUIUtility.wideMode ? 16.0 : 0.0) + 16.0) +
                        (float)((((MultilineAttribute)customAttributes[i]).lines - 1) * 13);
                }
                else if (customAttributes[i] is TextAreaAttribute)
                {
                    PropertyInfo propertyInfo = typeof(EditorGUIUtility).GetProperty("contextWidth",
                        BindingFlags.Static | BindingFlags.NonPublic);
                    float contextWidth = (float)propertyInfo.GetValue(null, null);

                    TextAreaAttribute textAreaAttribute = (TextAreaAttribute)customAttributes[i];
                    return 32f + (float)((Mathf.Clamp(Mathf.CeilToInt(EditorStyles.textArea.CalcHeight(
                        new GUIContent(property.stringValue), contextWidth) / 13f),
                        textAreaAttribute.minLines, textAreaAttribute.maxLines) - 1) * 13);
                }
            }

            return base.GetPropertyHeight(property, label);
        }

        /// <inheritdoc />
        public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
        {
            // Retrieve attributes
            List<ConditionalAttribute> conditionalAttributes = new List<ConditionalAttribute>();

            // ColorUsageAttribute colorUsageAttribute = null;
#if UNITY_5_3_OR_NEWER
            DelayedAttribute delayedAttribute = null;
#endif
            MultilineAttribute multilineAttribute = null;
            TextAreaAttribute textAreaAttribute = null;
            RangeAttribute rangeAttribute = null;
            ReadOnlyAttribute readOnlyAttribute = null;

            object[] customAttributes = fieldInfo.GetCustomAttributes(false);
            for (int i = 0; i < customAttributes.Length; i++)
            {
                if (customAttributes[i] is ConditionalAttribute)
                {
                    conditionalAttributes.Add((ConditionalAttribute)customAttributes[i]);
                }
                // else if (customAttributes[i] is ColorUsageAttribute)
                // {
                //     colorUsageAttribute = (ColorUsageAttribute)customAttributes[i];
                // }
#if UNITY_5_3_OR_NEWER
                else if (customAttributes[i] is DelayedAttribute)
                {
                    delayedAttribute = (DelayedAttribute)customAttributes[i];
                }
#endif
                else if (customAttributes[i] is MultilineAttribute)
                {
                    multilineAttribute = (MultilineAttribute)customAttributes[i];
                }
                else if (customAttributes[i] is TextAreaAttribute)
                {
                    textAreaAttribute = (TextAreaAttribute)customAttributes[i];
                }
                else if (customAttributes[i] is RangeAttribute)
                {
                    rangeAttribute = (RangeAttribute)customAttributes[i];
                }
                else if (customAttributes[i] is ReadOnlyAttribute)
                {
                    readOnlyAttribute = (ReadOnlyAttribute)customAttributes[i];
                }
                else if (customAttributes[i] is TooltipAttribute ||
                    customAttributes[i] is SerializeField ||
                    customAttributes[i] is NonSerializedAttribute)
                {
                    // Ignored attributes
                }
                else
                {
                    Debug.LogWarning("ConditionalPropertyDrawer needs implementation for type " + customAttributes[i].ToString());
                }
            }

            int conditionCount = 0;
            for (int i = 0; i < conditionalAttributes.Count; i++)
            {
                if (conditionalAttributes[i].Conditions != null)
                {
                    conditionCount += conditionalAttributes[i].Conditions.Length;
                }
            }

            ConditionalAttribute.Condition[] conditions = new ConditionalAttribute.Condition[conditionCount];

            int index = 0;
            for (int i = 0; i < conditionalAttributes.Count; i++)
            {
                if (conditionalAttributes[i].Conditions != null)
                {
                    ConditionalAttribute.Condition[] conds = conditionalAttributes[i].Conditions;
                    for (int j = 0; j < conds.Length; j++)
                    {
                        conditions[index++] = conds[j];
                    }
                }
            }

            Attribute.Show = true;
            try
            {
                Attribute.Show = ShouldShow(property, conditions);
            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }

            if (Attribute.Show)
            {
                if (readOnlyAttribute != null)
                {
                    GUI.enabled = false;
                }

                // Implementations obtained through inspection
#if UNITY_5_3_OR_NEWER
                if (delayedAttribute != null)
                {
                    PropertyDrawer propertyDrawer = GetPropertyDrawer("UnityEditor.DelayedDrawer,UnityEditor");
                    propertyDrawer.OnGUI(position, property, label);
                }
                else
#endif
/*                 if (colorUsageAttribute != null)
                {

                    EditorGUI.BeginChangeCheck();
#if UNITY_5_3_OR_NEWER
                    ColorPickerHDRConfig hdrConfig = new ColorPickerHDRConfig(
                        colorUsageAttribute.minBrightness, colorUsageAttribute.maxBrightness,
                        colorUsageAttribute.minExposureValue, colorUsageAttribute.maxExposureValue);
                    Color color = EditorGUI.ColorField(position, label, property.colorValue,
                        true, colorUsageAttribute.showAlpha, colorUsageAttribute.hdr, hdrConfig);
#else
                                        Color color = EditorGUI.ColorField(position, label, property.colorValue);
#endif
                    if (EditorGUI.EndChangeCheck())
                    {
                        property.colorValue = color;
                    }
                } 
                else 
                */
                if (multilineAttribute != null)
                {
                    PropertyDrawer propertyDrawer = GetPropertyDrawer("UnityEditor.MultilineDrawer,UnityEditor");
                    propertyDrawer.OnGUI(position, property, label);
                }
                else if (textAreaAttribute != null)
                {
                    PropertyDrawer propertyDrawer = GetPropertyDrawer("UnityEditor.TextAreaDrawer,UnityEditor");
                    propertyDrawer.OnGUI(position, property, label);
                }
                else if (rangeAttribute != null)
                {
                    if (property.propertyType == SerializedPropertyType.Float)
                    {
                        EditorGUI.Slider(position, property, rangeAttribute.min, rangeAttribute.max, label);
                    }
                    else if (property.propertyType == SerializedPropertyType.Integer)
                    {
                        EditorGUI.IntSlider(position, property, (int)rangeAttribute.min, (int)rangeAttribute.max, label);
                    }
                    else
                    {
                        EditorGUI.LabelField(position, label.text, "Use Range with float or int.");
                    }
                }
                else
                {
                    EditorGUI.PropertyField(position, property, label, false);
                }

                if (readOnlyAttribute != null)
                {
                    GUI.enabled = true;
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="property"></param>
        /// <param name="conditions"></param>
        /// <returns></returns>
        private static bool ShouldShow(SerializedProperty property,
            ConditionalAttribute.Condition[] conditions)
        {
            if (conditions == null || conditions.Length == 0)
            {
                return true;
            }

            string propertyPath = property.propertyPath;
            int index = propertyPath.LastIndexOf(".");
            propertyPath = propertyPath.Substring(0, index + 1);

            bool previous = false;
            for (int i = 0; i < conditions.Length; i++)
            {
                // Find SerializedProperty used for condition
                var conditionalProperty = property.serializedObject.FindProperty(
                    propertyPath + conditions[i].PropertyName);

                object propertyValue;
                if (conditionalProperty.propertyType == SerializedPropertyType.Integer)
                {
                    propertyValue = conditionalProperty.intValue;
                }
                else if (conditionalProperty.propertyType == SerializedPropertyType.Float)
                {
                    propertyValue = conditionalProperty.floatValue;
                }
                else if (conditionalProperty.propertyType == SerializedPropertyType.Boolean)
                {
                    propertyValue = conditionalProperty.boolValue;
                }
                else if (conditionalProperty.propertyType == SerializedPropertyType.Color)
                {
                    propertyValue = conditionalProperty.colorValue;
                }
                else if (conditionalProperty.propertyType == SerializedPropertyType.Enum)
                {
                    // Depending on what RHS param was passed in, parse the enum differently
                    if (conditions[i].Value.GetType().IsEnum)
                    {
                        // Grab the enum value from the enum type
                        propertyValue = Enum.Parse(conditions[i].Value.GetType(),
                            conditionalProperty.enumNames[conditionalProperty.enumValueIndex]);
                    }
                    else if (conditions[i].Value.GetType() == typeof(string))
                    {
                        // If it is a string, grab the name
                        propertyValue = conditionalProperty.enumNames[conditionalProperty.enumValueIndex];
                    }
                    else
                    {
                        // Otherwise use index (if number was passed in)
                        propertyValue = conditionalProperty.enumValueIndex;
                    }
                }
                else
                {
                    throw new Exception("SerializedPropertyType " + conditionalProperty.propertyType +
                        " needs to be implemented in ConditionalPropertyDrawer.ShouldShow.");
                }

                bool test = Check(propertyValue, conditions[i].Operator, conditions[i].Value);

                if (i != 0)
                {
                    switch (conditions[i - 1].Logical)
                    {
                        case ConditionalAttribute.Logical.And:
                            test = test && previous;
                            break;
                        case ConditionalAttribute.Logical.Or:
                            test = test || previous;
                            break;
                    }
                }

                previous = test;
            }

            return previous;
        }

        private static bool Check(object propertyValue, ConditionalAttribute.Operator @operator, object value)
        {
            if (!(propertyValue is IComparable) || !(value is IComparable))
            {
                throw new Exception("Either propertyValue or value is not IComparable");
            }

            switch (@operator)
            {
                case ConditionalAttribute.Operator.Equals:
                    return ((IComparable)propertyValue).CompareTo(value) == 0;
                case ConditionalAttribute.Operator.NotEquals:
                    return ((IComparable)propertyValue).CompareTo(value) != 0;
                case ConditionalAttribute.Operator.EqualsOrGreaterThan:
                    return ((IComparable)propertyValue).CompareTo(value) >= 0;
                case ConditionalAttribute.Operator.EqualsOrLessThan:
                    return ((IComparable)propertyValue).CompareTo(value) <= 0;
                case ConditionalAttribute.Operator.GreaterThan:
                    return ((IComparable)propertyValue).CompareTo(value) > 0;
                case ConditionalAttribute.Operator.LessThan:
                    return ((IComparable)propertyValue).CompareTo(value) < 0;
            }

            return false;
        }

        private static PropertyDrawer GetPropertyDrawer(string typeName)
        {
            PropertyDrawer propertyDrawer = null;

            try
            {
                Type type = Type.GetType(typeName);
                propertyDrawer = (PropertyDrawer)Activator.CreateInstance(type);
            }
            catch (TypeLoadException e)
            {
                Debug.LogException(e);
            }

            return propertyDrawer;
        }
    }
}
