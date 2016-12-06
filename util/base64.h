#ifndef _UTIL_BASE64_H
#define _UTIL_BASE64_H
#include <string>  
#include <vector>  
namespace util{
	std::string base64_encode(unsigned char const* , unsigned int len);  
	std::string base64_decode(std::string const& s);  
}

#endif
