<!-- File: resources/views/partials/sidebar.blade.php (Updated excerpt) -->

<ul class="sidebar-menu">
    @foreach (auth()->user()->businesses as $business)
        <li>
            <a href="#">{{ $business->name }}</a>
            <ul>
                @foreach ($business->facilities as $facility)
                    <li>
                        <a href="#">{{ $facility->name }}</a>
                        <ul>
                            @foreach ($facility->subFacilities as $subFacility)
                                @php
                                    $lastCheck = $subFacility->healthChecks()->latest()->first();
                                    $isOverdue = $lastCheck ? now()->diffInMinutes($lastCheck->checked_at) > $subFacility->check_interval_minutes : true;
                                    $lastBackwash = $subFacility->backwashLogs()->latest()->first();
                                    $isBackwashOverdue = $lastBackwash ? now()->diffInDays($lastBackwash->date) > $subFacility->backwash_interval_days : true;
                                    $class = $isOverdue || $isBackwashOverdue ? 'overdue' : '';
                                @endphp
                                <li class="{{ $class }}">
                                    <a href="{{ route('health-checks.index', $subFacility) }}">{{ $subFacility->name }}</a>
                                    <!-- Add link to backwash-logs if needed -->
                                </li>
                            @endforeach
                        </ul>
                    </li>
                @endforeach
            </ul>
        </li>
    @endforeach
</ul>

<style>
    .overdue { color: red; font-weight: bold; }
</style>

<!-- Add links under Facility/SubFacility, e.g., -->
<li><a href="{{ route('external-hire-clubs.index', $facility) }}">External Hires</a></li>
<li><a href="{{ route('annual-inspection-items.index') }}">Annual Inspections</a></li>
