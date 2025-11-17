<div>
    @foreach(\App\Models\Business::all() as $business)
        <div class="menu-item">
            <a href="#" class="menu-link">{{ $business->name }}</a>
            @foreach($business->facilities as $facility)
                <div class="submenu">
                    <a href="#">{{ $facility->name }}</a>
                    @foreach($facility->subFacilities as $sf)
                        <a href="/sub-facilities/{{ $sf->id }}/checks"
                           class="menu-link {{ in_array($sf->id, $overdue) ? 'text-danger font-weight-bold' : '' }}">
                            {{ $sf->name }} {{ in_array($sf->id, $overdue) ? ' (OVERDUE!)' : '' }}
                        </a>
                    @endforeach
                </div>
            @endforeach
        </div>
    @endforeach
</div>
