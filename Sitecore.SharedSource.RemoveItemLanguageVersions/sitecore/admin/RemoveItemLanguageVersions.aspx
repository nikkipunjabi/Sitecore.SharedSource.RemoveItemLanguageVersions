<%@ Page Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="Sitecore.Data" %>
<%@ Import Namespace="Sitecore.Data.Items" %>
<%@ Import Namespace="Sitecore.Globalization" %>
<%@ Import Namespace="Sitecore.Diagnostics" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="Sitecore.Data.Managers" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Remove Item Languages</title>

    <style>
        body {
            font-family: verdana, arial, sans-serif;
        }

        table {
            table-layout: fixed;
            width: 100%;
        }

            table.table-style-three {
                font-family: verdana, arial, sans-serif;
                font-size: 11px;
                color: #333333;
                border-width: 1px;
                border-color: #3A3A3A;
                border-collapse: collapse;
            }

                table.table-style-three th {
                    border-width: 1px;
                    padding: 8px;
                    border-style: solid;
                    border-color: #FFA6A6;
                    background-color: #D56A6A;
                    color: #ffffff;
                }

                table.table-style-three tr:nth-child(even) td {
                    background-color: #DDC;
                }

                table.table-style-three td {
                    border-width: 1px;
                    padding: 8px;
                    border-style: solid;
                    background-color: #ffffff;
                }

        #chkLang {
            text-align: center;
            margin-left: auto;
            margin-right: auto;
            width: auto;
        }

        .removeChildItemVersion {
            vertical-align: middle;
            margin-bottom: 10px;
        }
    </style>
    <script language="CS" runat="server"> 

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            if (Sitecore.Context.User.IsAdministrator == false)
            {
                Response.Write("You are not authorized to access. Login as administrator to access this tool.");
                phContainer.Visible = false;
                //Response.Redirect("login.aspx?returnUrl=removeitemlanguageversions.aspx");
            }
            else
            {
                if (IsPostBack) return;

                foreach (string dbname in Sitecore.Configuration.Factory.GetDatabaseNames())
                {
                    if (dbname.ToLower() != "core" && dbname.ToLower() != "filesystem")
                    {
                        drpDB.Items.Add(new ListItem(dbname));
                    }
                }

                if (drpDB.Items != null && drpDB.Items.Count > 0)
                {
                    var installedLanguages = LanguageManager.GetLanguages(Sitecore.Configuration.Factory.GetDatabase(drpDB.Items[0].Value));
                    if (installedLanguages != null)
                    {
                        foreach (var lang in installedLanguages)
                        {
                            chkLang.Items.Add(lang.Name);
                        }
                    }
                }
            }
        }

        protected void btnRemove_Click(object sender, EventArgs e)
        {
            int count = 0;
            StringBuilder sb = new StringBuilder();
            try
            {
                sb.Append("Item Language Versions Remove Summary:").Append("<br/>");
                string[] s = txtIDs.Text.Split(new string[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
                string DB = drpDB.SelectedItem.Value;
                Database db = Database.GetDatabase(DB);
                string log = string.Format("User: {0} started RemoveItemLanguage Tool.", Sitecore.Context.User.Name);
                Log.Info(log, this);
                foreach (string ii in s)
                {
                    count++;
                    foreach (ListItem lang in chkLang.Items)
                    {
                        if (lang.Selected)
                        {

                            RemoveLanguageVersion(ii, lang.Value, sb, db, ref count);
                        }
                    }
                }
                sb.Append("Total items processed: " + count).Append("<br/>");
            }
            catch (Exception ex)
            {
                sb.Append("Some Error Occurred. Message: ").Append(ex.Message).Append("<br/>");
                //lblError.Text = ex.ToString();
                Log.Error("Removed Item Language Tool. Some Error Occurred", ex, this);
            }
            lblError.Text = sb.ToString();
        }

        public void RemoveLanguageVersion(string rootItemPath, string languageCode, StringBuilder sb, Database db, ref int count)
        {
            string log = string.Empty;
            try
            {
                Language languageRemove = Sitecore.Globalization.Language.Parse(languageCode);
                Item rootItem = db.GetItem(rootItemPath, languageRemove);
                if (rootItem == null || rootItem.ID.ToString() == "{F344DBE2-BC34-49FB-8564-FD74048702D9}") { sb.Append(" Item not found: " + rootItemPath).Append("<br/>"); return; }
                if (rootItem != null)
                {
                    using (new Sitecore.SecurityModel.SecurityDisabler())
                    {
                        if (rootItem.Versions.Count == 0)
                        {
                            sb.Append("Language version not found. Item: " + rootItemPath).Append(" Language: ").Append(languageCode).Append("<br/>");
                        }
                        else
                        {
                            //Remove All Versions from Item
                            rootItem.Versions.RemoveAll(false);

                            sb.Append("Removed Item Language. Item ID:").Append(rootItem.ID).Append(" Language: ").Append(languageCode).Append("<br/>");
                            log = string.Format("Removed Item Language. Item Path: {0}, Language Version Removed: {1} ", rootItem.Paths.FullPath, languageCode);
                            Log.Info(log, this);
                        }

                        if (removeChildItemVersion.Checked)
                        {
                            //Remove language version recursively from child items of root item
                            foreach (Item child in rootItem.Axes.GetDescendants().Where(x => x.Language == languageRemove))
                            {
                                count++;
                                if (child.Versions.Count > 0)
                                {
                                    child.Versions.RemoveAll(false);
                                    sb.Append("Removed Child Item Language. Item ID:").Append(child.ID).Append(" Language: ").Append(languageCode).Append("<br/>");
                                    log = string.Format("Removed Child Item Language. Item Path: {0}, Language Version Removed: {1} ", child.Paths.FullPath, languageCode);
                                    Log.Info(log, this);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception)
            {
                sb.Append("Error while processing. Item: ").Append(rootItemPath).Append(" Language: ").Append(languageCode).Append("<br/>");
            }
        }
    </script>
</head>
<body>
    <asp:PlaceHolder ID="phContainer" runat="server">
        <form id="form1" runat="server">
            <h3 style="margin-left: 10px;">Bulk Remove Item Language Versions</h3>

            <table class="table-style-three">
                <tr>
                    <td style="width: 20%">Select Languages To Remove from Items
                    </td>
                    <td style="width: 90%">
                        <div style="float: left">
                            Provide Items Path or ID
                        </div>
                        <div style="float: right">
                            Database:
                        <asp:DropDownList ID="drpDB" runat="server">
                            <%--<asp:ListItem Text="Master" Value="master"></asp:ListItem>--%>
                            <%--<asp:ListItem Text="Web" Value="web"></asp:ListItem>--%>
                        </asp:DropDownList>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:CheckBoxList ID="chkLang" runat="server">
                        </asp:CheckBoxList>
                    </td>
                    <td style="vertical-align: top">
                        <asp:TextBox ID="txtIDs" TextMode="MultiLine" Rows="20" runat="server" Height="80%" Width="98%"></asp:TextBox></td>
                </tr>
                <tr>
                    <td colspan="2" class="submitParent" style="text-align: center">
                        <div class="removeChildItemVersion">
                            <asp:CheckBox ID="removeChildItemVersion" runat="server" Text="Remove Child Item Versions" Checked="false" />
                        </div>
                        <div class="btnRemoveChildItemVersion">
                            <asp:Button ID="btnRemove" runat="server" Text="Remove" OnClick="btnRemove_Click" />
                        </div>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <asp:Label ID="lblError" runat="server"></asp:Label>
                    </td>
                </tr>
            </table>
        </form>
    </asp:PlaceHolder>
</body>
</html>
