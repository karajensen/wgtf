
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//
//  file_info.hpp
//
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//  Copyright (c) Wargaming.net. All rights reserved.
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#ifndef FILE_INFO_H_
#define FILE_INFO_H_

#pragma once

namespace wgt
{
namespace FileInfoDetails
{
std::string normalizePath(std::string path)
{
	std::replace(path.begin(), path.end(),
		FilePath::kAltDirectorySeparator, FilePath::kDirectorySeparator);
	return path;
}
std::string localPath(std::string fullPath)
{
	fullPath = normalizePath(fullPath);
	auto end = fullPath.find_last_not_of("/\\");
	auto begin = fullPath.find_last_of("/\\", end);
	return fullPath.substr(begin + 1, end - begin);
}
}

class FileInfo : public IFileInfo
{
public:
	FileInfo()
	    : size_(0), created_(0), modified_(0), accessed_(0), fullPath_(""), absolutePath_(""), name_(""),
	      attributes_(FileAttributes::None)
	{
	}

	FileInfo(uint64_t size, uint64_t created, uint64_t modified, uint64_t accessed, const std::string& fullPath,
	         const std::string& absolutePath, FileAttributes::FileAttribute attributes)
	    : size_(size)
		, created_(created)
		, modified_(modified)
		, accessed_(accessed)
		, fullPath_( std::move( FileInfoDetails::normalizePath(fullPath) ) )
	    , absolutePath_( std::move( FileInfoDetails::normalizePath(absolutePath) ) )
		, name_( std::move( FileInfoDetails::localPath(fullPath) ))
		, attributes_(attributes)
	{
	}

	bool isDirectory() const override
	{
		return (attributes_ & FileAttributes::Directory) == FileAttributes::Directory;
	}

	bool isReadOnly() const override
	{
		return (attributes_ & FileAttributes::ReadOnly) == FileAttributes::ReadOnly;
	}

	bool isHidden() const override
	{
		return (attributes_ & FileAttributes::Hidden) == FileAttributes::Hidden;
	}

	bool isDots() const override
	{
		return isDirectory() && fullPath_->length() > 0 && fullPath_->back() == '.';
	}

	const SharedString & name() const override
	{
		return name_;
	}

	const char* extension() const override
	{
		auto index = fullPath_->rfind(FilePath::kExtensionSeparator);
		return index != std::string::npos ? &fullPath_->c_str()[index + 1] : "";
	}

	const SharedString & fullPath() const override
	{
		return fullPath_;
	}

	const SharedString & absolutePath() const override
	{
		return absolutePath_;
	}

	uint64_t size() const override
	{
		return size_;
	}
	uint64_t created() const override
	{
		return created_;
	}
	uint64_t modified() const override
	{
		return modified_;
	}
	uint64_t accessed() const override
	{
		return accessed_;
	}

	const FileAttributes::FileAttribute attributes() const override
	{
		return attributes_;
	}

private:
	const uint64_t size_;
	const uint64_t created_;
	const uint64_t modified_;
	const uint64_t accessed_;
	const SharedString fullPath_;
	const SharedString absolutePath_;
	const SharedString name_;

	const FileAttributes::FileAttribute attributes_;
};
} // end namespace wgt
#endif // FILE_INFO_H_
