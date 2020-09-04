using System;
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
    /// <example>
    /// class MyBehaviour : MonoBehaviour
    /// {
    ///     public bool showAdvanced;
    ///     
    ///     [Conditional("showAdvanced", true)]
    ///     public float advancedSetting = 1.0f;
    ///     
    ///     public float minDistance = 0.0f;
    /// 
    ///     [Conditional("minDistance", ConditionalAttribute.Operator.GreaterThan, 0.0f)]
    ///     public float minDistanceDeviation = 0.0f;
    /// }
    /// </example>
    [AttributeUsage(AttributeTargets.Field, AllowMultiple = true)]
    public class ConditionalAttribute : PropertyAttribute
    {
        /// <summary>
        /// 
        /// </summary>
        public enum Operator
        {
            /// <summary>
            /// 
            /// </summary>
            Equals,
            /// <summary>
            /// 
            /// </summary>
            NotEquals,
            /// <summary>
            /// 
            /// </summary>
            GreaterThan,
            /// <summary>
            /// 
            /// </summary>
            LessThan,
            /// <summary>
            /// 
            /// </summary>
            EqualsOrGreaterThan,
            /// <summary>
            /// 
            /// </summary>
            EqualsOrLessThan
        }

        /// <summary>
        /// 
        /// </summary>
        public enum Logical
        {
            /// <summary>
            /// 
            /// </summary>
            And,
            /// <summary>
            /// 
            /// </summary>
            Or
        }

        /// <summary>
        /// 
        /// </summary>
        public enum IsAnyOf
        {
            /// <summary>
            /// 
            /// </summary>
            Yes,
            /// <summary>
            /// 
            /// </summary>
            No
        }

        /// <summary>
        /// 
        /// </summary>
        public enum IsBetween
        {
            /// <summary>
            /// 
            /// </summary>
            ExclusiveYes,
            /// <summary>
            /// 
            /// </summary>
            ExclusiveNo,
            /// <summary>
            /// 
            /// </summary>
            InclusiveYes,
            /// <summary>
            /// 
            /// </summary>
            InclusiveNo
        }

        /// <summary>
        /// 
        /// </summary>
        public struct Condition
        {
            /// <summary>
            /// 
            /// </summary>
            public string PropertyName;
            /// <summary>
            /// 
            /// </summary>
            public Operator Operator;
            /// <summary>
            /// 
            /// </summary>
            public object Value;
            /// <summary>
            /// 
            /// </summary>
            public Logical Logical;

            /// <summary>
            /// 
            /// </summary>
            /// <param name="propertyName"></param>
            /// <param name="operator"></param>
            /// <param name="value"></param>
            /// <param name="logical"></param>
            public Condition(string propertyName, Operator @operator,
                object value, Logical logical)
            {
                PropertyName = propertyName;
                Operator = @operator;
                Value = value;
                Logical = logical;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public Condition[] Conditions;

        /// <summary>
        /// 
        /// </summary>
        public bool Show = true;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="propertyNames"></param>
        /// <param name="operators"></param>
        /// <param name="values"></param>
        /// <param name="logicals"></param>
        public ConditionalAttribute(string[] propertyNames, int[] operators,
            object[] values, int[] logicals)
        {
            Conditions = new Condition[propertyNames.Length];

            for (int i = 0; i < Conditions.Length; i++)
            {
                Conditions[i].PropertyName = propertyNames[i];

                if (i < operators.Length)
                {
                    Conditions[i].Operator = (Operator)operators[i];
                }
                else
                {
                    // Set to == if no operator was given
                    Conditions[i].Operator = Operator.Equals;
                }

                if (i < values.Length)
                {
                    Conditions[i].Value = values[i];
                }
                else
                {
                    // Set to last value if no value was given
                    Conditions[i].Value = values[values.Length - 1];
                }

                if (i < logicals.Length)
                {
                    Conditions[i].Logical = (Logical)logicals[i];
                }
                else
                {
                    // Set it to && if no value was given
                    Conditions[i].Logical = Logical.And;
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="propertyName"></param>
        /// <param name="values"></param>
        public ConditionalAttribute(string propertyName, params object[] values)
            : this(propertyName, IsAnyOf.Yes, values)
        {

        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="propertyName"></param>
        /// <param name="isAnyOff"></param>
        /// <param name="values"></param>
        public ConditionalAttribute(string propertyName, IsAnyOf isAnyOf, params object[] values)
        {
            Conditions = new Condition[values.Length];

            switch (isAnyOf)
            {
                case IsAnyOf.Yes:
                    for (int i = 0; i < Conditions.Length; i++)
                    {
                        Conditions[i] = new Condition(propertyName, Operator.Equals, values[i], Logical.Or);
                    }
                    break;
                case IsAnyOf.No:
                    for (int i = 0; i < Conditions.Length; i++)
                    {
                        Conditions[i] = new Condition(propertyName, Operator.NotEquals, values[i], Logical.And);
                    }
                    break;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="propertyName"></param>
        /// <param name="isBetween"></param>
        /// <param name="min"></param>
        /// <param name="max"></param>
        public ConditionalAttribute(string propertyName, IsBetween isBetween, object min, object max)
        {
            Conditions = new Condition[2];

            Conditions[0] = new Condition(propertyName, Operator.Equals, min, Logical.And);
            Conditions[1] = new Condition(propertyName, Operator.Equals, max, Logical.And);

            switch (isBetween)
            {
                case IsBetween.ExclusiveYes:
                    Conditions[0].Operator = Operator.GreaterThan;
                    Conditions[1].Operator = Operator.LessThan;
                    break;
                case IsBetween.ExclusiveNo:
                    Conditions[0].Operator = Operator.LessThan;
                    Conditions[1].Operator = Operator.GreaterThan;
                    break;
                case IsBetween.InclusiveYes:
                    Conditions[0].Operator = Operator.EqualsOrGreaterThan;
                    Conditions[1].Operator = Operator.EqualsOrLessThan;
                    break;
                case IsBetween.InclusiveNo:
                    Conditions[0].Operator = Operator.EqualsOrLessThan;
                    Conditions[1].Operator = Operator.EqualsOrGreaterThan;
                    break;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="propertyName"></param>
        /// <param name="value"></param>
        public ConditionalAttribute(string propertyName, object value)
        {
            Conditions = new Condition[1];

            Conditions[0] = new Condition(propertyName, Operator.Equals, value, Logical.And);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="propertyName"></param>
        /// <param name="value"></param>
        /// <param name="logical"></param>
        public ConditionalAttribute(string propertyName, object value, int logical)
        {
            Conditions = new Condition[1];

            Conditions[0] = new Condition(propertyName, Operator.Equals, value, (Logical)logical);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="propertyName"></param>
        /// <param name="operator"></param>
        /// <param name="value"></param>
        public ConditionalAttribute(string propertyName, Operator @operator, object value)
        {
            Conditions = new Condition[1];

            Conditions[0] = new Condition(propertyName, @operator, value, Logical.And);
        }

        /// <summary>
        /// 
        /// </summary>
        public ConditionalAttribute()
        {

        }
    }
}
