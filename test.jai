DEBUG :: true;


main :: () {
    perf_init();
    args := get_command_line_arguments();

    pool: Pool;
    set_allocators(*pool);
    testpool : Allocator = .{pool_allocator_proc, *pool};

    if args.count > 1 {
        print("-🞂 % \n", args[1]);
        str := read_entire_file(args[1]);
        start_time := current_time_monotonic();
        root, result := xml_parse(str);
        end_time := current_time_monotonic();
        print("    % %\n", ifx result.status == .ok then "🟢" else "🔴", result.status);
        if result.status != .ok return;
        print("Structure:\n%", xml_write(root));
        print("Parser time: %µs\n", to_microseconds(end_time-start_time));
        // B/ns = GB/s :-)
        print("Bandwidth: % GB/s\n", cast(float) str.count / to_nanoseconds(end_time-start_time));
        return;
    }

    test_files := quick_sort(file_list("test_data", recursive=true), compare_strings);

    passed: int;
    failed: int;

    for file:test_files {
        print(" 🟣 % ", file);
        str := read_entire_file(file);
        start_time := current_time_monotonic();
        root, result := xml_parse(str,, testpool);
        end_time := current_time_monotonic();
        time_microseconds := to_microseconds(end_time-start_time);
        bandwidth := cast(float) str.count / to_nanoseconds(end_time-start_time);
        if result.status != .ok {
            using result;
            print("\r % % - % - % µs - % GB/s\n", ifx status == .ok then "🟢" else "🔴", file, status, time_microseconds, bandwidth);
            failed += 1;
            print(" - Error     : [%] % at %:%\n", status, error_message, line, char);
        } else {
            print("\r");
            passed += 1;
        }
        free(str);
        reset(*pool);
        
        // print("Structure:\n%", xml_write(root));
    }
    print("\n");
    print_perf_report();

    total := passed+failed;
    print("Passed: % (%2%%)\n", passed, formatFloat(100*passed/cast(float)total, 2));
    print("Failed: % (%2%%)\n", failed, formatFloat(100*failed/cast(float)total, 2));
    print("Total : %\n", total);
}

#load "module.jai";
#load "performance.jai";
#import "Basic";
#import "File";
#import "File_Utilities";
#import "Sort";
#import "Pool";
