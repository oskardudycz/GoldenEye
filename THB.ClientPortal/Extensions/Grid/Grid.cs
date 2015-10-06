using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;
using System.Reflection;
using System.ComponentModel.DataAnnotations;
using System.Collections;
using System.Linq.Expressions;
using System.Security;
using System.Resources;
using Frontend.Web;

namespace Frontend.Web.Extensions.Grid
{
    public class Grid<TRow> : IGrid<TRow>
        where TRow : class
    {
        private TagBuilder _grid;
        private IList<GridColumn> _columns;
        private IList<TRow> _model;

        public Grid(IList<TRow> model)
        {
            _model = model;
            _grid = new TagBuilder("table");
            _grid.AddCssClass("col-md-12 table text-left table-hover table-striped table-condensed");
            _columns = new List<GridColumn>();
        }
        public IGrid<TRow> AutoGenerateColumns()
        {
            var propertiesToDisplay = _model.GetType().GetGenericArguments().FirstOrDefault()
                                       .GetProperties()
                                       .Where(x => x.CustomAttributes.FirstOrDefault(y => y.AttributeType == typeof(DisplayAttribute)) != null);

            //  var resource = new ResourceReader("");

            foreach (var property in propertiesToDisplay)
            {
                var attribute = property.CustomAttributes.FirstOrDefault(x => x.AttributeType == typeof(DisplayAttribute));
                if (attribute == null) continue;
                var displayName = attribute.NamedArguments.FirstOrDefault().TypedValue.Value.ToString();
                //var resx = attribute.NamedArguments.FirstOrDefault(). TODO Finish him!!!
                try
                {
                    string name = (string)typeof(Resources).GetProperty(displayName).GetValue(Resources.Add, null);
                    _columns.Add(new GridColumn(name, name));
                }
                catch (NullReferenceException ex)
                {
                    _columns.Add(new GridColumn(property.Name, displayName));
                }
                InsertValues(_columns.Last(), property);
            }

            return this;
        }

        public IGrid<TRow> Columns(Action<IGrid<TRow>> action)
        {
            action.Invoke(this);
            return this;
        }
        public GridColumn AddColumn<TProperty>(Expression<Func<TRow, TProperty>> expression)
        {
            var memberExpression = expression.Body as MemberExpression;
            if (memberExpression == null)
            {
                return null;
            }
            var propertyName = memberExpression.Member.Name;
            var customAttributeData = memberExpression.Member.CustomAttributes
                .FirstOrDefault(x => x.AttributeType == typeof(DisplayAttribute));
            if (customAttributeData != null)
            {
                if (customAttributeData
                    .NamedArguments != null)
                {
                    var displayName = customAttributeData
                        .NamedArguments.FirstOrDefault().TypedValue.Value.ToString();
                    _columns.Add(new GridColumn(propertyName, displayName));
                }
            }

            InsertValues(_columns.LastOrDefault(), expression.Compile());
            return _columns.LastOrDefault();
        }
        //public TripDetailsRow AddRow<TProperty>(Expression<Func<TModel, TProperty>> property)
        //{
        //    var value = property.Compile()((_model));
        //    _rows.Add(new TripDetailsRow(value));
        //    return _rows.Last();
        //}
        public GridColumn AddColumn(Expression<Func<TRow, MvcHtmlString>> expression)
        {
            _columns.Add(new GridColumn());
            InsertValues(_columns.LastOrDefault(), expression.Compile());
            return _columns.LastOrDefault();
        }

        private void InsertValues<TProperty>(GridColumn column, Func<TRow, TProperty> value)
        {
            foreach (var item in _model)
            {
                column.Insert(value(item));
            }
        }
        private void InsertValues(GridColumn column, PropertyInfo value)
        {
            foreach (var item in _model)
            {
                column.Insert(value.GetValue(item));
            }
        }

        public MvcHtmlString Build()
        {
            var headerBuilder = new TagBuilder("thead");
            foreach (var column in _columns)
            {
                var cell = new TagBuilder("th");
                if (!string.IsNullOrWhiteSpace(column.Icon))
                {
                    var i = new TagBuilder("i");
                    i.AddCssClass("glyphicon " + column.Icon);
                    cell.InnerHtml = i.ToString();
                }
                cell.InnerHtml += column.DisplayName;
                headerBuilder.InnerHtml += cell.ToString();
            }
            _grid.InnerHtml = headerBuilder.ToString();
            for (int i = 0; i < _model.Count; i++)
            {
                var row = new TagBuilder("tr");
                foreach (var column in _columns)
                {
                    var cell = new TagBuilder("td");
                    cell.InnerHtml = (column.Values[i] == null) ? String.Empty : column.Values[i].ToString();
                    row.InnerHtml += cell.ToString();
                }
                _grid.InnerHtml += row.ToString();
            }
            return new MvcHtmlString(_grid.ToString());
        }

    }
}
