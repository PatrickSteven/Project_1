﻿using System.Web;
using System.Web.Optimization;

namespace Project_1
{
    public static class BundleConfig
    {
        // For more information on bundling, visit https://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/lib").Include(
                        "~/Scripts/jquery-{version}.js",
                        "~/Scripts/DataTables/jquery.dataTables.js",
                        "~/Scripts/DataTables/dataTables.bootstrap4.js",
                        "~/Scripts/bootstrap.js",
                        "~/Scripts/bootbox.js"
                        ));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                        "~/Scripts/jquery.validate*"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at https://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new StyleBundle("~/Content/css").Include(
                      "~/Content/bootstrap-lux.css",
                      "~/Content/DataTables/css/dataTables.bootstrap4.css",
                      "~/Content/Site.css"));
        }

        public static IHtmlString RenderDefer(params string[] paths)
        {
            return Scripts.RenderFormat(@"<script src='{0}' defer></script>", paths);
        }
    }
}
