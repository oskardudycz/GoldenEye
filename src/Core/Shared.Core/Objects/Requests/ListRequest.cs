﻿using System.Collections.Generic;

namespace GoldenEye.Shared.Core.Objects.Requests
{
    /// <summary>
    /// Class to send list of records from service
    /// </summary>
    public class ListRequest<T> : RequestBase, IListRequest<T>
    {
        /// <summary>
        /// List of records
        /// </summary>
        public IList<T> Items { get; }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="items">List of records</param>
        private ListRequest(IList<T> items)
        {
            Items = items;
        }

        /// <summary>
        /// Creation metod of class object
        /// </summary>
        /// <param name="items">List of records</param>
        /// <returns></returns>
        public static ListRequest<T> Create(IList<T> items)
        {
            if (items == null)
                items = new List<T>();

            return new ListRequest<T>(items);
        }
    }
}