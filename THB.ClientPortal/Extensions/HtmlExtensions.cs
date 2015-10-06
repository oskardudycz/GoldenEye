using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Html;
using Frontend.Web.Extensions.Grid;

namespace Frontend.Web.Extensions
{
    public static class HtmlExtensions
    {
        public static IGrid<TRow> RenderGrid<TRow>(this HtmlHelper htmlHelper, IList<TRow> model)
        where TRow : class
        {
            return new Grid<TRow>(model);
        }
    }
}