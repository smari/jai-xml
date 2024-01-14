
perf_init :: () {
    perf_start_time = current_time_monotonic();
    print("Performance monitoring enabled. % timers\n", total_performance_timers);
}

performance_timer :: ($$name: string) #expand {
    index := #run perf_get_or_create_timer(name);
    performance_timers[index].name = name;  // Runtime override to prevent crashes!
    #if DEBUG {
        ts_start := current_time_monotonic();
        `defer {
            ts_end := current_time_monotonic();
            perf_add_time(index, ts_end-ts_start);
        }
    }
}

print_perf_report :: () {
    s := perf_report();
    print("%", s);
    free(s);
}

perf_report :: () -> string {
    buf : String_Builder;

    cur_time := current_time_monotonic();
    total_runtime := cur_time - perf_start_time;
    append(*buf, tprint("Runtime: % µs.\n", to_microseconds(total_runtime)));
    for 0..total_performance_timers-1 {
        pt := performance_timers[it];
        percent := to_milliseconds(pt.total_time) * 100 / to_milliseconds(total_runtime);
        append(*buf, tprint("  %  : % µs (% %%) over % calls", 
            ifx pt.name then pt.name else "???", 
            to_microseconds(pt.total_time), percent, pt.total_calls,
        ));
        if pt.total_calls == 0 { 
            append(*buf, ".\n"); 
        } else {
            if to_milliseconds(pt.total_time) / pt.total_calls > 10 {
                append(*buf, tprint(" (~% ms per call).\n", to_milliseconds(pt.total_time) / pt.total_calls));
            } else if to_microseconds(pt.total_time) / pt.total_calls > 10 {
                append(*buf, tprint(" (~% µs per call).\n", to_microseconds(pt.total_time) / pt.total_calls));
            } else {
                append(*buf, tprint(" (~% ns per call).\n", to_nanoseconds(pt.total_time) / pt.total_calls));
            }
        }
    }

    return builder_to_string(*buf);
}

#scope_file



PerformanceTimer :: struct {
    name        : string;
    total_time  : Apollo_Time;
    total_calls : int;
}


MAX_PERFORMANCE_TIMERS :: 128;
#no_reset total_performance_timers := 0;
#no_reset performance_timers : [MAX_PERFORMANCE_TIMERS]PerformanceTimer;
perf_start_time : Apollo_Time;

perf_get_or_create_timer :: (name: string) -> int {
    // performance_timers[total_performance_timers].name = name;
    for 0..total_performance_timers-1 {
        if performance_timers[it].name == name {
            return it;
        }
    }
    total_performance_timers += 1;
    print("Created performance timer % in slot %\n", name, total_performance_timers-1);
    return total_performance_timers-1;
}

perf_add_time :: (idx: int, time: Apollo_Time) {
    performance_timers[idx].total_time += time;
    performance_timers[idx].total_calls += 1;
}
