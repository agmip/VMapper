<nav class="navbar navbar-default navbar-fixed-top navbar-inverse">
    <div class="container-fluid">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navBar">
              <span class="glyphicon glyphicon-menu-hamburger"></span>
            </button>
            <a class="navbar-brand navbar-static-top"><img src="/images/LOGO.png" height="125%" alt="Decision Support System for Agrotechnology Transfer"></a>
        </div>
        <div class="collapse navbar-collapse" id="navBar">
            <ul class="nav navbar-nav">
                <li class="active">
                    <a href="/"><span class="glyphicon glyphicon-home"></span> Home</a>
                </li>
    <!--            <li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><span class="glyphicon glyphicon-grain"></span> Simulation <span class="caret"></span></a>
                    <ul class="dropdown-menu" role="menu">
                        <li><a href="/simulation/afsirs"><span class="glyphicon glyphicon-file"></span> AFSIRS</a></li>
                    </ul>
                </li>-->
    <!--            <li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><span class="glyphicon glyphicon-tint"></span> Water Use <span class="caret"></span></a>
                    <ul class="dropdown-menu" role="menu">
                        <li><a href="/wateruse/permit/create"><span class="glyphicon glyphicon-file"></span> Create Permit </a></li>
                        <li><a href="/wateruse/permit/list"><span class="glyphicon glyphicon-list-alt"></span> Permit List </a></li>
                        <li><a href="/wateruse/permit/search" class="hidden"><span class="glyphicon glyphicon-search"></span> Search Permit </a></li>
                    </ul>
                </li>-->
                <li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><span class="glyphicon glyphicon-briefcase"></span> Data Tools <span class="caret"></span></a>
                    <ul class="dropdown-menu" role="menu">
                        <li><a href="/demo/xbuilder2d"><span class="glyphicon glyphicon-edit"></span> XBuilder 2D</a></li>
                        <li><a href="/demo/gbuilder1d"><span class="glyphicon glyphicon-picture"></span> GBuilder 1D</a></li>
                        <li><a href="/demo/gbuilder2d"><span class="glyphicon glyphicon-picture"></span> GBuilder 2D</a></li>
                        <li><a href="/demo/xmleditor"><span class="glyphicon glyphicon-edit"></span> XML Editor</a></li>
                        <li><a href="/demo/unit"><span class="glyphicon glyphicon-edit"></span> Unit Master</a></li>
                        <li><a href="#" onClick="window.open('https://dssat2d-plot-demo.herokuapp.com/')"><span class="glyphicon glyphicon-send"></span> Distributable Plot</a></li>
                    </ul>
                </li>
    <!--            <li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><span class="glyphicon glyphicon-folder-close"></span> Document <span class="caret"></span></a>
                    <ul class="dropdown-menu" role="menu">
                        <li><a href="#" onClick="window.open('/doc/afsirs/AFSIRS_Technical_Manual.pdf', 'AFSIRS Technical Manual')"><span class="glyphicon glyphicon-book"></span> AFSIRS Technical Manual</a></li>
                        <li><a href="#" onClick="window.open('/doc/afsirs/AFSIRS_User_Guide.pdf', 'AFSIRS Technical Manual')"><span class="glyphicon glyphicon-book"></span> AFSIRS User Guide</a></li>
                    </ul>
                </li>-->
                <li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><span class="glyphicon glyphicon-question-sign"></span> Help <span class="caret"></span></a>
                    <ul class="dropdown-menu" role="menu">
                        <li><a href="#" onClick="window.open('https://bitbucket.org/mengz/gbuilder2d/issues')"><span class="glyphicon glyphicon-pencil"></span> Report Issues</a></li>
                    </ul>
                </li>
            </ul>
            <ul class="nav navbar-nav navbar-right">
                <#if currentUser?? >
                <li class="active navbar-left">
                    <a>Hello, ${currentUser}</a>
                </li>
                <li class="navbar-defalut">
                    <a href="/logout"><span class="glyphicon glyphicon-log-out"></span> Logout&nbsp;&nbsp;&nbsp;&nbsp;</a>
                </li>
                <#else>
<!--                <li class="navbar-left">
                    <a href="/login"><span class="glyphicon glyphicon-log-in"></span> Login</a>
                </li>
                <li class="navbar-defalut">
                    <a href="/register"><span class="glyphicon glyphicon-user"></span> Register&nbsp;&nbsp;&nbsp;&nbsp;</a>
                </li>-->
                </#if>
            </ul>
        </div>
    </div><!-- /container -->
</nav><!-- /navbar wrapper -->