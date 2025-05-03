# 사용자 프로필 관리 컴포넌트 Component

## Overview
이 컴포넌트는 사용자 프로필 정보를 표시하고 편집할 수 있는 기능을 제공합니다. 사용자 정보 조회, 수정, 프로필 이미지 업로드 기능을 포함합니다.

## Component Structure

### Component
```tsx
import React, { useState, useEffect } from 'react';
import { Button, TextField, Avatar, Box, Typography, Grid, CircularProgress } from '@mui/material';
import { getUserProfile, updateUserProfile, uploadProfileImage } from '../api/userApi';
import { UserProfile } from '../types/user';
import ImageUploader from './ImageUploader';

const UserProfileComponent: React.FC<UserProfileProps> = ({ userId }) => {
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  useEffect(() => {
    const fetchProfile = async () => {
      setIsLoading(true);
      try {
        const data = await getUserProfile(userId);
        setProfile(data);
        setError(null);
      } catch (err) {
        setError('프로필을 불러오는 중 오류가 발생했습니다.');
        console.error(err);
      } finally {
        setIsLoading(false);
      }
    };
    
    fetchProfile();
  }, [userId]);
  
  const handleSave = async (updatedProfile: UserProfile) => {
    setIsLoading(true);
    try {
      await updateUserProfile(userId, updatedProfile);
      setProfile(updatedProfile);
      setIsEditing(false);
      setError(null);
    } catch (err) {
      setError('프로필 저장 중 오류가 발생했습니다.');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };
  
  const handleImageUpload = async (file: File) => {
    setIsLoading(true);
    try {
      const imageUrl = await uploadProfileImage(userId, file);
      setProfile(prev => prev ? { ...prev, imageUrl } : null);
      setError(null);
    } catch (err) {
      setError('이미지 업로드 중 오류가 발생했습니다.');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };
  
  if (isLoading && !profile) {
    return <CircularProgress />;
  }
  
  if (error && !profile) {
    return <Typography color="error">{error}</Typography>;
  }
  
  if (!profile) {
    return <Typography>프로필을 찾을 수 없습니다.</Typography>;
  }
  
  return (
    <Box sx={{ maxWidth: 600, margin: '0 auto', padding: 3 }}>
      <Grid container spacing={3}>
        <Grid item xs={12} display="flex" justifyContent="center">
          <Avatar
            src={profile.imageUrl}
            alt={profile.name}
            sx={{ width: 120, height: 120 }}
          />
        </Grid>
        
        {isEditing ? (
          <ProfileEditForm 
            profile={profile} 
            onSave={handleSave} 
            onCancel={() => setIsEditing(false)}
            onImageUpload={handleImageUpload}
          />
        ) : (
          <ProfileDisplay 
            profile={profile} 
            onEdit={() => setIsEditing(true)} 
          />
        )}
      </Grid>
    </Box>
  );
};

export default UserProfileComponent;
```

### Props Interface
```typescript
interface UserProfileProps {
  userId: string;
}

interface ProfileDisplayProps {
  profile: UserProfile;
  onEdit: () => void;
}

interface ProfileEditFormProps {
  profile: UserProfile;
  onSave: (profile: UserProfile) => void;
  onCancel: () => void;
  onImageUpload: (file: File) => void;
}
```

### State Interface
```typescript
interface UserProfileState {
  profile: UserProfile | null;
  isEditing: boolean;
  isLoading: boolean;
  error: string | null;
}
```

## Dependencies

