<div class="navbar-custom">
    <ul class="list-unstyled topbar-right-menu float-right mb-0">
        <li class="dropdown notification-list">
            <a class="nav-link dropdown-toggle nav-user arrow-none mr-0" data-toggle="dropdown" href="#" role="button">
                <span class="account-user-avatar"><img src="{{ auth()->user()->avatar ?? asset('osen/images/users/avatar-1.jpg') }}" alt="user" class="rounded-circle"></span>
                <span><span class="account-user-name">{{ auth()->user()->name }}</span><span class="account-position">{{ auth()->user()->rank ?? 'Staff' }}</span></span>
            </a>
            <div class="dropdown-menu dropdown-menu-right">
                <a href="{{ route('logout') }}" class="dropdown-item"><i class="mdi mdi-logout"></i> Logout</a>
            </div>
        </li>
    </ul>
    <button class="button-menu-mobile open-left disable-btn"><i class="mdi mdi-menu"></i></button>
    <div class="app-search"><h4>Leisure Facility Manager</h4></div>
</div>
