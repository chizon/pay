TARGET  := $(strip $(TARGET))
TYPE    := $(strip $(TYPE))
INSTALL_DIR := $(strip $(INSTALL_DIR))
CC       = gcc
CXX      = g++
CPP      = cpp
CFLAGS   += $(C_INC)
CXXFLAGS += $(C_INC)
CFLAGS	 += $(EXTRA_CFLAGS) 
CXXFLAGS += $(EXTRA_CXXFLAGS)

CFLAGS	 += -Wall -Werror
CXXFLAGS += -Wall -Werror

CXXFLAGS += -DTEST_SERVER -DLEPOSPAY_SHOULD_SENDSMS -std=c++0x -Wno-pmf-conversions
SYS_LIB += libpthread librt libz libssl libcurl libxml2 libmysqlclient libiconv
LIB_DIR += /usr/lib/ /usr/lib64/ /usr/lib64/mysql/
C_INC    = $(INC_DIR:%=-I%)
C_LIB    = $(LIB_DIR:%=-L%) $(LIB_DEPENDS:lib%=-l%) $(SYS_LIB:lib%=-l%)
INC_DIR  += $(COMM_INC_DIR)
INC_DIR  += /usr/include/mysql/ /usr/local/mysql/include/mysql/ /usr/include/libxml2/ ../ ./ ../
LIB_DIR  += $(COMM_LIB_DIR)
SRC_DIR  += .

C_SRC   = $(wildcard $(SRC_DIR:%=%/*.c))
CXX_SRC = $(wildcard $(SRC_DIR:%=%/*.cpp))
C_OBJ   = $(C_SRC:%.c=%.o)
CXX_OBJ = $(CXX_SRC:%.cpp=%.o)
C_DEP   = $(C_SRC:%.c=%.d)
CXX_DEP = $(CXX_SRC:%.cpp=%.d)

ALL_OBJ = $(C_OBJ) $(CXX_OBJ)
ALL_DEP = $(C_DEP) $(CXX_DEP)

ALL_GCNO = $(ALL_OBJ:%.o=%.gcno)

TARGET_INSTALL = $(INSTALL_DIR)/$(TARGET)
SO_DEPENDS = $(LIB_DEPENDS:%=$(COMM_LIB_DIR)/%.so) 

ifeq ($(debug), 1)
CFLAGS   += -g -DDEBUG_GLOBAL --coverage
CXXFLAGS += -g -DDEBUG_GLOBAL --coverage
LDFLAGS  += --coverage
else
CFLAG += -DNDEBUG
CXXFLAGS += -DNDEBUG
endif

.PHONY: all clean install

all: $(TARGET)

clean:
	rm -rf $(ALL_OBJ) $(ALL_DEP) $(TARGET) $(ALL_GCNO)

$(C_DEP): %.d : %.c
	$(CPP) $(EXTRA_CFLAGS) $(C_INC) -M $< > $@

$(CXX_DEP): %.d : %.cpp
	$(CPP) $(EXTRA_CXXFLAGS) $(C_INC) -M $< > $@


ifneq ($(MAKECMDGOALS), clean)
-include $(ALL_DEP)
endif


ifeq ($(TYPE), app)
$(TARGET): $(ALL_DEP) $(ALL_OBJ) $(OBJ_DEPENDS)
	$(CXX) $(C_LIB) $(ALL_OBJ) $(OBJ_DEPENDS) $(LDFLAGS) -o $@
install: all
	cp -f $(TARGET) $(TARGET_INSTALL)
else
ifeq ($(TYPE), lib)
$(TARGET):$(ALL_DEP) $(ALL_OBJ) $(OBJ_DEPENDS)
	$(AR) r $(TARGET) $(ALL_OBJ)
	cp -f $(TARGET) $(TARGET_INSTALL)
install:all
	cp -f $(TARGET) $(TARGET_INSTALL)
else
ifeq ($(TYPE), so)
CFLAGS   += -fPIC
CXXFLAGS += -fPIC
$(TARGET): $(ALL_DEP) $(ALL_OBJ) $(SO_DEPENDS) $(OBJ_DEPENDS)
	$(CXX) -shared -fPIC $(C_LIB) $(ALL_OBJ) $(OBJ_DEPENDS) $(LDFLAGS) -o $@
install: all
	cp -f $(TARGET) $(TARGET_INSTALL)
else
ifeq ($(TYPE), obj)
.PHONY: $(TARGET)
$(TARGET): $(ALL_DEP) $(ALL_OBJ)
install: all
else
$(error $$(TYPE) should be 'app', 'so' or 'obj', but not '$(TYPE)')
endif
endif
endif
endif 
