#include <stdint.h>
#include <math.h>
#include <vx_intrinsics.h>
#include <vx_spawn.h>
#include "common.h"

typedef void (*PFN_Kernel)(int task_id, kernel_arg_t* arg);

void kernel_ror(int task_id, kernel_arg_t* arg) {
	uint32_t count    = arg->task_size;
	int32_t* src0_ptr = (int32_t*)arg->src0_addr;
	int32_t* src1_ptr = (int32_t*)arg->src1_addr;
	int32_t* dst_ptr  = (int32_t*)arg->dst_addr;	
	uint32_t offset = task_id * count;

	for (uint32_t i = 0; i < count; ++i) {
		int32_t a = src0_ptr[offset+i];
		int32_t b = src1_ptr[offset+i];
		int32_t c = vx_ror(a, b);
		dst_ptr[offset+i] = c;
	}
}

void kernel_rol(int task_id, kernel_arg_t* arg) {
	uint32_t count    = arg->task_size;
	int32_t* src0_ptr = (int32_t*)arg->src0_addr;
	int32_t* src1_ptr = (int32_t*)arg->src1_addr;
	int32_t* dst_ptr  = (int32_t*)arg->dst_addr;	
	uint32_t offset = task_id * count;

	for (uint32_t i = 0; i < count; ++i) {
		int32_t a = src0_ptr[offset+i];
		int32_t b = src1_ptr[offset+i];
		int32_t c = vx_rol(a, b);
		dst_ptr[offset+i] = c;
	}
}

// void kernel_rori(int task_id, kernel_arg_t* arg) {
// 	uint32_t count    = arg->task_size;
// 	int32_t* src0_ptr = (int32_t*)arg->src0_addr;
// 	int32_t* src1_ptr = (int32_t*)arg->src1_addr;
// 	int32_t* dst_ptr  = (int32_t*)arg->dst_addr;	
// 	uint32_t offset = task_id * count;

// 	for (uint32_t i = 0; i < count; ++i) {
// 		int32_t a = src0_ptr[offset+i];
// 		int32_t b = src1_ptr[offset+i];
// 		int32_t c = vx_rori(a, b);
// 		dst_ptr[offset+i] = c;
// 	}
// }

static const PFN_Kernel sc_tests[] = {
	kernel_ror,
	kernel_rol,
	//kernel_rori,
};

void main() {
	kernel_arg_t* arg = (kernel_arg_t*)KERNEL_ARG_DEV_MEM_ADDR;
	vx_spawn_tasks(arg->num_tasks, (vx_spawn_tasks_cb)sc_tests[arg->testid], arg);
}