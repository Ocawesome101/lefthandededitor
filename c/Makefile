BUILD_DIR ?= ./bin
CC ?= gcc
# LHE left hand edit
TARGET_EXEC = lhe

SRC_DIRS ?= ./
SRCS=$(wildcard $(SRC_DIRS)*.c)
OBJS=$(SRCS:%.c=$(BUILD_DIR)/%.o)

$(TARGET_EXEC): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)
	@echo done

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	$(RM) -r $(TARGET_EXEC) $(BUILD_DIR)
