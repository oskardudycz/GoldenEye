using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace Frontend.Web.Extensions.Grid
{
    public interface IGrid<TRow>
        where TRow : class
    {
        IGrid<TRow> AutoGenerateColumns();
        MvcHtmlString Build();
        IGrid<TRow> Columns(Action<IGrid<TRow>> action);
        GridColumn AddColumn<TProperty>(Expression<Func<TRow, TProperty>> expression);
        GridColumn AddColumn(Expression<Func<TRow, MvcHtmlString>> expression);
    }
}
