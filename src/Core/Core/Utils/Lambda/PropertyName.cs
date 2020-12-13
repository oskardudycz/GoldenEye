using System;
using System.Linq.Expressions;

namespace GoldenEye.Core.Utils.Lambda
{
    /// <summary>
    ///     Pobranie nazwy właściwości lub pola z wykorzystaniem wyrażeń lambda.
    /// </summary>
    /// <remarks>
    ///     http://www.lesnikowski.com/blog/index.php/property-name-from-lambda
    /// </remarks>
    public static class PropertyName
    {
        /// <summary>
        ///     Metoda zwraca na podstawie wyrażenia lambda nazwę właściwości lub pola.
        /// </summary>
        /// <param name="expression">
        ///     Wyrażenie lambda, na podstawie którego nastąpi
        ///     szukanie nazwy właściwości lub pola.
        /// </param>
        /// <returns>Nazwa właściwości lub pola.</returns>
        /// <example>
        ///     Przykład użycia:
        ///     <code>
        ///     PropertyName.For&lt;OrgUnitTreeViewModel&gt;(x =&gt; x.SelectedTreeItem))
        /// </code>
        /// </example>
        public static string For<T>(Expression<Func<T, object>> expression)
        {
            var body = expression.Body;
            return GetMemberName(body);
        }

        /// <summary>
        ///     Metoda zwraca na podstawie wyrażenia lambda nazwę właściwości lub pola.
        /// </summary>
        /// <param name="expression">
        ///     Wyrażenie lambda, na podstawie którego nastąpi
        ///     szukanie nazwy właściwości lub pola.
        /// </param>
        /// <returns>Nazwa właściwości lub pola.</returns>
        /// <example>
        ///     Przykład użycia:
        ///     <code>
        ///     PropertyName.For(() =&gt; this.SelectedTreeItem)
        /// </code>
        /// </example>
        public static string For(Expression<Func<object>> expression)
        {
            var body = expression.Body;
            return GetMemberName(body);
        }

        public static string For<T, TP>(Expression<Func<T, TP>> expression)
        {
            var body = expression.Body;
            return GetMemberName(body);
        }

        public static string GetMemberName(Expression expression)
        {
            var memberExpression = expression as MemberExpression;
            if (memberExpression != null)
            {
                if (memberExpression.Expression != null &&
                    memberExpression.Expression.NodeType == ExpressionType.MemberAccess)
                    return GetMemberName(memberExpression.Expression) + "." + memberExpression.Member.Name;
                return memberExpression.Member.Name;
            }

            var unaryExpression = expression as UnaryExpression;
            if (unaryExpression != null)
            {
                if (unaryExpression.NodeType != ExpressionType.Convert)
                    throw new Exception(string.Format("Cannot interpret member from {0}", expression));
                return GetMemberName(unaryExpression.Operand);
            }

            throw new Exception(string.Format("Could not determine member from {0}", expression));
        }
    }
}
