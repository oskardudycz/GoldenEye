using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Frontend.Web.Extensions.Grid
{
    public class GridColumn
    {
        private string _displayName;
        private string _propertyName;
        private string _icon;
        private IList<object> _values;

        public GridColumn(string propertyName = "", string displayName = "")
        {
            _displayName = displayName;
            _propertyName = propertyName;
            _icon = string.Empty;
            _values = new List<object>();
        }

        public GridColumn Named(string name)
        {
            _displayName = name;
            return this;
        }
        public GridColumn WithIcon(string name)
        {
            _icon = name;
            return this;
        }
        internal void Insert(object value)
        {
            _values.Add(value);
        }
        internal string PropertyName
        {
            get { return _propertyName; }
        }
        internal string DisplayName
        {
            get { return _displayName; }
        }
        internal IList<object> Values
        {
            get { return _values; }
        }
        internal string Icon
        {
            get { return _icon; }
        }
    }
}