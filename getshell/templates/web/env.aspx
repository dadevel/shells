<%@ Page Language="C#" Debug="true" Trace="false" EnableViewState="false" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.IO" %>
<%
aaaa.Text = Environment.GetEnvironmentVariable("USERDOMAIN") + "/" + Environment.GetEnvironmentVariable("USERNAME");
%>
<html>
<body>
<pre><asp:Literal runat="server" id="aaaa" mode="encode"/></pre>
</body>
</html>
