<!DOCTYPE html>
<html>
    <head>
        <#include "header.ftl">
    </head>

    <body>

        <#include "nav.ftl">

        <div id="myCarousel" class="carousel slide" data-ride="carousel">
            <!-- Indicators -->
            <ol class="carousel-indicators">
                <li data-target="#myCarousel" data-slide-to="0" class="active"></li>
                <li data-target="#myCarousel" data-slide-to="1"></li>
                <li data-target="#myCarousel" data-slide-to="2"></li>
            </ol>

            <!-- Wrapper for slides -->
            <div class="carousel-inner" role="listbox" style="max-height:50vh">
                <div class="item active">
                    <img src="images/2-1-S.jpg" alt="field" width="1200" height="300" style="max-height:50vh">
                    <div class="carousel-caption ">
                        <h3>AFSIRS Online Prototype</h3>
                        <p>Simulate the water usage</p>
                    </div>
                </div>

                <div class="item">
                    <img src="images/2-2-S.jpg" alt="field" width="1200" height="300" style="max-height:50vh">
                    <div class="carousel-caption">
                        <h3>AFSIRS Online Prototype</h3>
                        <p>Collect site information</p>
                    </div>      
                </div>

                <div class="item">
                    <img src="images/2-3-S.jpg" alt="field" width="1200" height="300" style="max-height:50vh">
                    <div class="carousel-caption">
                        <h3>AFSIRS Online  Prototype</h3>
                        <p>Manage soil and water use data</p>
                    </div>      
                </div>
            </div>

            <!-- Left and right controls -->
            <a class="left carousel-control" href="#myCarousel" role="button" data-slide="prev">
                <span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>
                <span class="sr-only">Previous</span>
            </a>
            <a class="right carousel-control" href="#myCarousel" role="button" data-slide="next">
                <span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span>
                <span class="sr-only">Next</span>
            </a>
        </div>

        <div class="container">

            <div class="container-fluid text-left">
                <h3>To run AFSIRS module</h3>
                <ol>
                    <li>Select Soil Map from menu bar under Data Tools</li>
                    <li>Draw a polygon on the map to get the soil data for your field</li>
                    <li>Select Create Permit from menu bar under Water Use</li>
                    <li>Input your site info and configure your simulation</li>
                    <li>Once you save your Permit, you can find it in the Permit List page</li>
                    <li>Find Run AFSIRS button on the list page, and click it to show the graph or download as PDF file</li>
                </ol>
            </div>
            <hr>
            <div class="container-fluid text-left">
                <h3>Browser Support</h3>
                <p>To smoothly use the online AFSIRS, please check the following table and make sure your browser is supported.</p>
                <table class="table table-bordered table-striped text-center">
                    <tr>
                        <th style="width:16%;" title="Chrome" class="text-center"><img src="images/browsers/chrome.gif" alt="Chrome"></th>
                        <th style="width:16%;" title="Edge" class="text-center"><img src="images/browsers/edge.gif" alt="Edge"></th>
                        <th style="width:16%;" title="Internet Explorer" class="text-center"><img src="images/browsers/ie.gif" alt="Internet Explorer"></th>
                        <th style="width:16%;" title="Firefox" class="text-center"><img src="images/browsers/firefox.gif" alt="Firefox"></th>
                        <th style="width:16%;" title="Safari" class="text-center"><img src="images/browsers/safari.gif" alt="Safari"></th>
                        <th style="width:16%;" title="Opera" class="text-center"><img src="images/browsers/opera.gif" alt="Opera"></th>                
                    </tr>
                    <tr>
                        <td>Yes</td>
                        <td>Limited**</td>
                        <td>Limited**</td>
                        <td>Yes</td>
                        <td>Yes</td>
                        <td>Yes</td>
                    </tr>
                </table>
                <p>* Browsers which are not included in the above might face issue while using the web site.</p>
                <p>** By certain security configuration, Edge and IE might not work properly on Soil Map tool. Please try other browser if you have any issue with Edge or IE.</p>
            </div>

        </div>
        <#include "footer.ftl">

    </body>
</html>
