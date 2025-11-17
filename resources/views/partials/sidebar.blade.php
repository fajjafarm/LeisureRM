<div class="left-side-menu">
    @auth
        @foreach(auth()->user()->businesses as $business)
            <div class="menuitem">
                <a href="#" class="has-arrow">{{ $business->name }}</a>
                <ul class="submenu">
                    @foreach($business->facilities as $facility)
                        <li>
                            <a href="#" class="has-arrow">{{ $facility->name }}</a>
                            <ul class="sub-submenu">
                                @foreach($facility->subFacilities as $sub)
                                    @php $overdue = $sub->isOverdue(); @endphp
                                    <li>
                                        <a href="{{ route('subfacility.show', $sub) }}"
                                           class="{{ $overdue ? 'text-danger font-weight-bold' : '' }}">
                                            {{ $sub->name }}
                                            @if($overdue) (OVERDUE) @endif
                                        </a>
                                    </li>
                                @endforeach
                            </ul>
                        </li>
                    @endforeach
                </ul>
            </div>
        @endforeach
    @endauth
</div>
