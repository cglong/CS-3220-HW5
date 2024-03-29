library verilog;
use verilog.vl_types.all;
entity Fetch is
    port(
        I_CLOCK         : in     vl_logic;
        I_LOCK          : in     vl_logic;
        I_BranchPC      : in     vl_logic_vector(15 downto 0);
        I_BranchAddrSelect: in     vl_logic_vector(1 downto 0);
        I_BranchStallSignal: in     vl_logic;
        I_DepStallSignal: in     vl_logic;
        O_LOCK          : out    vl_logic;
        O_PC            : out    vl_logic_vector(15 downto 0);
        O_IR            : out    vl_logic_vector(31 downto 0);
        O_FetchStall    : out    vl_logic
    );
end Fetch;
