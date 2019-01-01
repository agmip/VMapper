<!DOCTYPE html>
<html>
    <head>
        <#include "header.ftl">
    </head>
    <style>
        th, td {
            padding: 5px;
            text-align: left;
        }
    </style>

    <body>

        <#include "nav.ftl">

        <div class="container">

            <h1>REGISTRATION PAGE</h1>
            <#if operation_result == "Failed" >
            <p>REGISTRATION FAILED</p>
            </#if>
            <form id="loginForm" method="post">
                <table>
                    <tr>
                        <td><label>User Name : </label></td>
                        <td><input type="text" name="username" placeholder="User Name" value="" required></td>
                    </tr>
                    <tr>
                        <td><label>Password : </label></td>
                        <td><input type="password" name="password" placeholder="Passowrd" value="" required></td>
                    </tr>
                    <tr>
                        <td><input type="submit" value="Register"></td>
                    </tr>
                </table>
            </form>
        </div>
        <#include "footer.ftl">

    </body>
</html>
